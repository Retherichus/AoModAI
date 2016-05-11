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
    int techID = cTechPigSticker;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    
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
// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getLoneWanderer
    inactive
    minInterval 36 //starts in cAge1
{
    if (kbGetTechStatus(cTechLoneWanderer) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LoneWanderer", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLoneWanderer);
        aiPlanSetDesiredPriority(x, 25);
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
    if (kbGetTechStatus(cTechEyesintheForest) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("EyesInTheForest", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEyesintheForest);
        aiPlanSetDesiredPriority(x, 20);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting EyesInTheForest");
    }
}

//age2
//Freyja
// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getThunderingHooves
    inactive
    minInterval 60 //starts in cAge2
    group Freyja
{
    float foodSupply = kbResourceGet(cResourceFood);

    if (kbGetAge() < cAge3 && foodSupply < 1000)
	return;
	
    if (kbGetTechStatus(cTechThunderingHooves) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ThunderingHooves", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechThunderingHooves);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ThunderingHooves");
    }
}

//==============================================================================
rule getAuroraBorealis
    inactive
    minInterval 60 //starts in cAge2
    group Freyja
{
    float goldSupply = kbResourceGet(cResourceGold);

    if (kbGetAge() < cAge3 && goldSupply < 650)
	return;
    if (kbGetTechStatus(cTechAuroraBorealis) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AuroraBorealis", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAuroraBorealis);
        aiPlanSetDesiredPriority(x, 10);
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
        aiPlanSetDesiredPriority(x, 100);
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
    float foodSupply = kbResourceGet(cResourceFood);

    if (kbGetAge() < cAge3 && foodSupply < 1000)
	return;
    if (kbGetTechStatus(cTechEldhrimnirKettle) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ElhrimnirKettle", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEldhrimnirKettle);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ElhrimnirKettle");
    }
}

//==============================================================================
rule getArcticWinds
    inactive
    minInterval 60 //starts in cAge2
    group Heimdall
{
    float woodSupply = kbResourceGet(cResourceWood);

    if (kbGetAge() < cAge3 && woodSupply < 450)
	return;
    if (kbGetTechStatus(cTechArcticWinds) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ArcticWinds", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechArcticWinds);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ArcticWinds");
    }
}


//Forseti
// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getHallOfThanes
    inactive
    minInterval 60 //starts in cAge2
    group Forseti
{
    float woodSupply = kbResourceGet(cResourceWood);
	
    if (kbGetAge() < cAge3 && woodSupply < 550)
	return;
    if (kbGetTechStatus(cTechHallofThanes) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HallOfThanes", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHallofThanes);
        aiPlanSetDesiredPriority(x, 15);
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
    float woodSupply = kbResourceGet(cResourceWood);
	
    if (kbGetAge() < cAge3 && woodSupply < 650)
	return;
    if (kbGetTechStatus(cTechHamarrtroll) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Hamarrtroll", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHamarrtroll);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Hamarrtroll");
    }
}

// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getMithrilBreastplate
    inactive
    minInterval 60 //starts in cAge2
    group Forseti
{
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (kbGetAge() < cAge3 && goldSupply < 650)
	return;
    if (kbGetTechStatus(cTechMithrilBreastplate) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("MithrilBreastplate", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechMithrilBreastplate);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting MithrilBreastplate");
    }
}


//age3
//Njord
// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getRingGiver
    inactive
    minInterval 60 //starts in cAge3
    group Njord
{
    if (kbGetTechStatus(cTechRingGiver) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RingGiver", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRingGiver);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting RingGiver");
    }
}

//==============================================================================
rule getLongSerpent
    inactive
    minInterval 60 //starts in cAge3
    group Njord
{
    if (kbGetTechStatus(cTechLongSerpent) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LongSerpent", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLongSerpent);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting LongSerpent");
    }
}

//==============================================================================
rule getWrathOfTheDeep
    inactive
    minInterval 60 //starts in cAge3
    group Njord
{
    if (kbGetTechStatus(cTechWrathOfTheDeep) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WrathOfTheDeep", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechWrathOfTheDeep);
        aiPlanSetDesiredPriority(x, 10);
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
    if (kbGetTechStatus(cTechRime) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Rime", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRime);
        aiPlanSetDesiredPriority(x, 25);
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

// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getHuntressAxe
    inactive
    minInterval 60 //starts in cAge3
    group Skadi
{
    if (kbGetTechStatus(cTechHuntressAxe) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HuntressAxe", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHuntressAxe);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting HuntressAxe");
    }
}

//Bragi
// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getSwineArray
    inactive
    minInterval 60 //starts in cAge3
    group Bragi
{
    if (kbGetTechStatus(cTechSwineArray) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SwineArray", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSwineArray);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SwineArray");
    }
}

// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getCallOfValhalla
    inactive
    minInterval 60 //starts in cAge3
    group Bragi
{
    if (kbGetTechStatus(cTechCallOfValhalla) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("CallOfValhalla", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCallOfValhalla);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting CallOfValhalla");
    }
}

//==============================================================================
rule getThurisazRune
    inactive
    minInterval 60 //starts in cAge3
    group Bragi
{
    if (kbGetTechStatus(cTechThurisazRune) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ThurisazRune", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechThurisazRune);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ThurisazRune");
    }
}


//age4
//Baldr
//==============================================================================
rule getArcticGale
    inactive
    minInterval 60 //starts in cAge4
    group Baldr
{
    if (kbGetTechStatus(cTechArcticGale) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ArcticGale", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechArcticGale);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ArcticGale");
    }
}

// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getSonsOfSleipnir
    inactive
    minInterval 60 //starts in cAge4
    group Baldr
{
    if (kbGetTechStatus(cTechSonsofSleipnir) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SonsOfSleipnir", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSonsofSleipnir);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SonsOfSleipnir");
    }
}

//==============================================================================
rule getDwarvenAuger
    inactive
    minInterval 60 //starts in cAge4
    group Baldr
{
    if (kbGetTechStatus(cTechDwarvenAuger) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DwarvenAuger", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDwarvenAuger);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting DwarvenAuger");
    }
}

//Tyr
// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getBerserkergang
    inactive
    minInterval 60 //starts in cAge4
    group Tyr
{
    if (kbGetTechStatus(cTechBerserkergang) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Berserkergang", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBerserkergang);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Berserkergang");
    }
}

// TODO: Do we really need this rule? If not remove it!
//==============================================================================
rule getBravery
    inactive
    minInterval 60 //starts in cAge4
    group Tyr
{
    if (kbGetTechStatus(cTechBravery) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Bravery", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBravery);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Bravery");
    }
}

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
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting GraniteBlood");
    }
}
