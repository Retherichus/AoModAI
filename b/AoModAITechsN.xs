//AoModAITechsN.xs
//This file contains all Norse god specific techs.
//by Loki_GdD

// TODO: finish the rules and start them in the main ai file

//Norse
//Thor
//==============================================================================
rule getPigSticker
    inactive
    minInterval 16 //starts in cAge1
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    int techID = cTechPigSticker;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("PigSticker", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 40);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting PigSticker");
    }
}

//Odin
//==============================================================================
rule getLoneWanderer
    inactive
    minInterval 36 //starts in cAge1
{
    
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAlive) < 10))
        return;
    if (kbGetTechStatus(cTechLoneWanderer) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LoneWanderer", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLoneWanderer);
        aiPlanSetDesiredPriority(x, 25);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting LoneWanderer");
    }
}


//Loki
//==============================================================================
rule getEyesInTheForest
    inactive
    minInterval 36 //starts in cAge1
{
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbGetAge() < cAge2))
        return;
    if (kbGetTechStatus(cTechEyesintheForest) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("EyesInTheForest", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEyesintheForest);
        aiPlanSetDesiredPriority(x, 20);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting EyesInTheForest");
    }
}

//age2
//Freyja
//==============================================================================
rule getAuroraBorealis
    inactive
    minInterval 60 //starts in cAge2
    group Freyja
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float goldSupply = kbResourceGet(cResourceGold);

    if ((kbGetAge() < cAge3) && (goldSupply < 650) || (kbUnitCount(cMyID, cUnitTypeValkyrie, cUnitStateAlive) < 3))
	return;
    if (kbGetTechStatus(cTechAuroraBorealis) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AuroraBorealis", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAuroraBorealis);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting AuroraBorealis");
    }
}


//Heimdall
//==============================================================================
rule getSafeguard
    inactive
    minInterval 60 //starts in cAge2
    group Heimdall
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechSafeguard) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechSafeguard, true) >= 0)
        return;
    
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
        return;
        
    if (kbGetTechStatus(cTechSafeguard) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Safeguard", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSafeguard);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsSetRuleMinIntervalSelf(300);
        if (ShowAiEcho == true) aiEcho("Getting Safeguard");
    }
}

//==============================================================================
rule getElhrimnirKettle
    inactive
    minInterval 60 //starts in cAge2
    group Heimdall
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float foodSupply = kbResourceGet(cResourceFood);

    if ((kbGetAge() < cAge3) && (foodSupply < 1000) || (kbUnitCount(cMyID, cUnitTypeEinheriar, cUnitStateAlive) < 2))
	return;
    if (kbGetTechStatus(cTechEldhrimnirKettle) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ElhrimnirKettle", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEldhrimnirKettle);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ElhrimnirKettle");
    }
}



//Forseti
//==============================================================================
rule getHallOfThanes
    inactive
    minInterval 60 //starts in cAge2
    group Forseti
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float woodSupply = kbResourceGet(cResourceWood);
	
    if (kbGetAge() < cAge3 && woodSupply < 550)
	return;
    if (kbGetTechStatus(cTechHallofThanes) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HallOfThanes", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHallofThanes);
        aiPlanSetDesiredPriority(x, 15);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting HallOfThanes");
    }
}


//==============================================================================
rule getHamarrtroll
    inactive
    minInterval 60 //starts in cAge2
    group Forseti
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float woodSupply = kbResourceGet(cResourceWood);
	
    if ((kbGetAge() < cAge3) && (woodSupply < 650) || (kbUnitCount(cMyID, cUnitTypeTroll, cUnitStateAlive) < 2))
	return;
    if (kbGetTechStatus(cTechHamarrtroll) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Hamarrtroll", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHamarrtroll);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Hamarrtroll");
    }
}

//age3
//Njord
//==============================================================================
rule getWrathOfTheDeep
    inactive
    minInterval 60 //starts in cAge3
    group Njord
{
    if (gTransportMap == false)
    {
        xsDisableSelf();
        return;
    }
	
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypeKraken, cUnitStateAlive) < 2))
        return;
    if (kbGetTechStatus(cTechWrathOfTheDeep) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WrathOfTheDeep", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechWrathOfTheDeep);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting WrathOfTheDeep");
    }
}


//Skadi
//==============================================================================
rule getRime
    inactive
    minInterval 60 //starts in cAge3
    group Skadi
{
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypeFrostGiant, cUnitStateAlive) < 2))
        return;
    if (kbGetTechStatus(cTechRime) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Rime", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRime);
        aiPlanSetDesiredPriority(x, 25);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Rime");
    }
}

//==============================================================================
rule getWinterHarvest
    inactive
    minInterval 60 //starts in cAge3
    group Skadi
{
    if (kbGetTechStatus(cTechWinterHarvest) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WinterHarvest", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechWinterHarvest);
        aiPlanSetDesiredPriority(x, 20);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting WinterHarvest");
    }
}


//Bragi
//==============================================================================
rule getSwineArray
    inactive
    minInterval 60 //starts in cAge3
    group Bragi
{
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive) < 5))
        return;
    if (kbGetTechStatus(cTechSwineArray) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SwineArray", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSwineArray);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SwineArray");
    }
}

//==============================================================================
rule getThurisazRune
    inactive
    minInterval 60 //starts in cAge3
    group Bragi
{
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbResourceGet(cResourceWood) < 350))
        return;
    if (kbGetTechStatus(cTechThurisazRune) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ThurisazRune", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechThurisazRune);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ThurisazRune");
    }
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
    if (kbGetTechStatus(cTechDwarvenAuger) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DwarvenAuger", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDwarvenAuger);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting DwarvenAuger");
    }
}
//==============================================================================
rule getSonsOfSleipnir
    inactive
    minInterval 60 //starts in cAge4
    group Baldr
{
    if ((kbUnitCount(cMyID, cUnitTypeRaidingCavalry, cUnitStateAlive) < 4) || (kbResourceGet(cResourceFood) < 400))
	return;
    if (kbGetTechStatus(cTechSonsofSleipnir) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SonsOfSleipnir", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSonsofSleipnir);
        aiPlanSetDesiredPriority(x, 10);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SonsOfSleipnir");
    }
}

//Tyr
//Hel
//==============================================================================
rule getRampage
    inactive
    minInterval 60 //starts in cAge4
    group Hel
{
    if (kbGetTechStatus(cTechRampage) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Rampage", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRampage);
        aiPlanSetDesiredPriority(x, 20);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Rampage");
    }
}

//==============================================================================
rule getGraniteBlood
    inactive
    minInterval 60 //starts in cAge4
    group Hel
{
    if (kbGetTechStatus(cTechGraniteBlood) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("GraniteBlood", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechGraniteBlood);
        aiPlanSetDesiredPriority(x, 20);
		aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting GraniteBlood");
    }
}
