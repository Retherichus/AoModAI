//AoModAITechsG.xs
//This file contains all Greek god specific techs.
//by Loki_GdD


//Greek
//Hades
//==============================================================================
rule getVaultsOfErebus
    minInterval 23 //starts in cAge2
    inactive
{
    int techID = cTechVaultsofErebus;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
    }

    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((foodSupply < 300) || (favorSupply < 10))
        return;
        
    if ((foodSupply < 950) && (foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
        return;
        
    //Get Vaults of Erebus.
    int voePID=aiPlanCreate("HadesVaultsOfErebus", cPlanResearch);
    if (voePID != 0)
    {
        aiPlanSetVariableInt(voePID, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(voePID, 50);
        aiPlanSetEscrowID(voePID, cEconomyEscrowID);
        aiPlanSetActive(voePID);
        if (ShowAiEcho == true) aiEcho("Getting vaults of erebus");
        xsSetRuleMinIntervalSelf(300);
    }
}

// TODO: Do we really need this rule? If not remove it!
//Poseidon
//==============================================================================
rule getLordOfHorses
    inactive
    minInterval 23 //starts in cAge2
{
    int techID = cTechLordofHorses;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;

    int numCavalry = kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateAlive);
    if ((numCavalry < 5) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
        return;
        
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((foodSupply < 300) || (favorSupply < 20))
        return;
        
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
        return;
        
    if (kbGetTechStatus(techID) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LordOfHorses", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 30);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting LordOfHorses");
        xsSetRuleMinIntervalSelf(300);
    }
}

//Zeus
//==============================================================================
rule getOlympicParentage
    minInterval 23 //starts in cAge2
    inactive
{
    int techID = cTechOlympicParentage;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechOlympicParentage, true) >= 0)
        return;
    
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

    //Get Olympic Parentage.
    int opPID=aiPlanCreate("GetOlympicParentage", cPlanResearch);
    if (opPID != 0)
    {
        aiPlanSetVariableInt(opPID, cResearchPlanTechID, 0, cTechOlympicParentage);
        aiPlanSetDesiredPriority(opPID, 25);
        aiPlanSetEscrowID(opPID, cMilitaryEscrowID);
        aiPlanSetActive(opPID);
        if (ShowAiEcho == true) aiEcho("Getting Olympic Parentage");
        xsSetRuleMinIntervalSelf(300);
    }
}

//age2
//Athena
//==============================================================================
rule getLabyrinthOfMinos
    inactive
    minInterval 20 //starts in cAge2
    group techsGreekMinorGodAge2
{       
    int techID = cTechLabyrinthofMinos;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
        return;
    
    int numArchers = kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateAlive);
    if ((numArchers > 8) && (kbGetTechStatus(cTechMediumArchers) < cTechStatusResearching))
        return;
    
    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
        return;
    
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 400) || (favorSupply < 20))
        return;

    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LabyrinthOfMinos", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting LabyrinthOfMinos");
        xsSetRuleMinIntervalSelf(300);
    }
}


//Hermes
//==============================================================================
rule getWingedMessenger
    inactive
    minInterval 27 //starts in cAge2
    group techsGreekMinorGodAge2
{
    int techID = cTechWingedMessenger;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((goldSupply < 100) || (favorSupply < 20))
        return;
        
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
        return;
        
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WingedMessenger", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetEscrowID(x, cEconomyEscrowID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting WingedMessenger");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getSylvanLore
    inactive
    minInterval 31 //starts in cAge2
    group techsGreekMinorGodAge2
{
    int techID = cTechSylvanLore;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
        return;
        
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if (((numFortresses < 1) || (numMarkets < 1)) && (kbGetAge() == cAge3))
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 600) || (favorSupply < 40))
        return;    
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SylvanLore", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 40);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting SylvanLore");
        xsSetRuleMinIntervalSelf(300);
    }
}


//Ares
//==============================================================================
rule getWillOfKronos
    inactive
    minInterval 33 //starts in cAge2
    group techsGreekMinorGodAge2
{
    int techID = cTechWillofKronos;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (techStatus < cTechStatusResearching)
        {
            if (((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
             || ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3)))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(33);
            }
        }
        return;
    }
    
    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
        return;
    
    if ((foodSupply < 400) || (favorSupply < 40))
        return;
        
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
        return;
    else if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
        return;

    static int count = 0;
    if (count < 2)
    {
        count = count + 1;
        return;
    }
        
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WillOfKronos", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 30);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting WillOfKronos");
        xsSetRuleMinIntervalSelf(11);
    }
}



//age3
//Aphrodite
//==============================================================================
rule getDivineBlood
    inactive
    minInterval 27 //starts in cAge3
    group techsGreekMinorGodAge3
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
    float favorSupply = kbResourceGet(cResourceFavor);
    
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
    
    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
        return;
    
    if (kbGetAge() == cAge3)
    {
        if ((foodSupply > 700) && (goldSupply > 700))
            return;
            
        if ((foodSupply < 400) || (favorSupply < 35))
            return;
    }
    else
    {
        if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 85))
            return;
    }
        
    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
    }
        
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DivineBlood", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 60);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting DivineBlood");
        xsSetRuleMinIntervalSelf(11);
    }
}

//==============================================================================
rule getGoldenApples
    inactive
    minInterval 29 //starts in cAge3
    group techsGreekMinorGodAge3
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
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("GoldenApples", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cEconomyEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting GoldenApples");
        xsSetRuleMinIntervalSelf(11);
    }
}


//==============================================================================
rule getRoarOfOrthus
    inactive
    minInterval 31 //starts in cAge3
    group techsGreekMinorGodAge3
{
    int techID = cTechRoarofOrthus;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (techStatus < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(31);
            }
        }
        return;
    }
    
    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
        return;
    
    if ((foodSupply < 600) || (favorSupply < 40))
        return;
        
    if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
        return;

    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
    }
        
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RoarOfOrthus", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting RoarOfOrthus");
        xsSetRuleMinIntervalSelf(11);
    }
}


//Apollo
//==============================================================================
rule getTempleOfHealing
    inactive
//    minInterval 17 //starts in cAge3
    minInterval 30 //starts in cAge3
    group techsGreekMinorGodAge3
{
    int techID = cTechTempleofHealing;
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
        x = aiPlanCreate("TempleOfHealing", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting TempleOfHealing");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getOracle
    inactive
    minInterval 31 //starts in cAge3
    group techsGreekMinorGodAge3
{
    int techID = cTechOracle;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
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
        
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Oracle", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Oracle");
        xsSetRuleMinIntervalSelf(300);
    }
}


//Dionysus
//==============================================================================
rule getBacchanalia
    inactive
    minInterval 33 //starts in cAge3
    group techsGreekMinorGodAge3
{
    int techID = cTechBacchanalia;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if ((numFortresses < 1) || (numMarkets < 1))
        return;

    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 600) || (favorSupply < 40))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Bacchanalia", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Bacchanalia");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getAnastrophe
    inactive
    minInterval 29 //starts in cAge3
    group techsGreekMinorGodAge3
{
    if (gTransportMap == false)
    {
        xsDisableSelf();
        return;
    }
    
    int techID = cTechAnastrophe;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    
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
    
    int numRammingShipGreek = kbUnitCount(cMyID, cUnitTypeRammingShipGreek, cUnitStateAlive);
    if ((numRammingShipGreek < 5) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
        return;
    
    if ((foodSupply < 600) || (favorSupply < 40))
        return;
    
    if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
        return;

    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
    }
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Anastrophe", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Anastrophe");
        xsSetRuleMinIntervalSelf(11);
    }
}


//age4
//Artemis
//==============================================================================
rule getFlamesOfTyphon
    inactive
    minInterval 29 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechFlamesofTyphon;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 70))
        return;
    
    if ((foodSupply < 800) || (favorSupply < 30))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FlamesOfTyphon", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting FlamesOfTyphon");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getTrierarch
    inactive
    minInterval 31 //starts in cAge4
    group techsGreekMinorGodAge4
{
    if (gTransportMap == false)
    {
        xsDisableSelf();
        return;
    }
    
    int techID = cTechTrierarch;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching)
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((goldSupply < 600) || (favorSupply < 60))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Trierarch", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 30);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Trierarch");
        xsSetRuleMinIntervalSelf(300);
    }
}

//Hephaestus
//==============================================================================
rule getForgeOfOlympus
    inactive
    minInterval 35 //starts in cAge4
    group techsGreekMinorGodAge4
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
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ForgeOfOlympus", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting ForgeOfOlympus");
        xsSetRuleMinIntervalSelf(11);
    }
}

//==============================================================================
rule getWeaponOfTheTitans
    inactive
    minInterval 29 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechWeaponoftheTitans;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching)
        {
            if ((favorSupply > 20) && (goldSupply > 500) && (foodSupply > 500) && (woodSupply > 500))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(29);
            }
        }
        return;
    }
    
    if (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching)
        return;
        
    int specialUnitID = -1;
    if (cMyCiv == cCivZeus)
        specialUnitID = cUnitTypeMyrmidon;
    else if (cMyCiv == cCivHades)
        specialUnitID = cUnitTypeCrossbowman;
    else if (cMyCiv == cCivPoseidon)
        specialUnitID = cUnitTypeHetairoi;
    
    int numSpecialUnits = kbUnitCount(cMyID, specialUnitID, cUnitStateAlive);
    if ((numSpecialUnits < 1) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
        return;
    
    
    if (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching)
    {
        if ((favorSupply < 40) && (goldSupply > 400) && (foodSupply > 400) && (woodSupply > 400))
            return;
    }
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WeaponOfTheTitans", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 80);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting WeaponOfTheTitans");
        xsSetRuleMinIntervalSelf(11);
    }
}

//==============================================================================
rule getHandOfTalos
    inactive
    minInterval 31 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechHandofTalos;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching)
        return;
    
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 600) || (favorSupply < 30))
        return;
    
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 75))
        return;
        
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HandOfTalos", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting HandOfTalos");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getShoulderOfTalos
    inactive
    minInterval 33 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechShoulderofTalos;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
    }
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching)
        return;
    
    if (kbGetTechStatus(cTechHandofTalos) < cTechStatusResearching)
        return;
    
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((goldSupply < 600) || (favorSupply < 30))
        return;
    
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 75))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ShoulderOfTalos", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting ShoulderOfTalos");
        xsSetRuleMinIntervalSelf(300);
    }
}


//Hera
//==============================================================================
rule getAthenianWall
    inactive
//    minInterval 27 //starts in cAge4
    minInterval 37 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechAthenianWall;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable) || (gBuildWalls == false))
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
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 80))
        return;
    
    if ((woodSupply < 800) || (favorSupply < 45))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AthenianWall", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting AthenianWall");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getMonstrousRage
    inactive
    minInterval 29 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechMonstrousRage;
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
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 75))
        return;
    
    if ((foodSupply < 500) || (favorSupply < 37))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("MonstrousRage", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting MonstrousRage");
        xsSetRuleMinIntervalSelf(300);
    }
}

//==============================================================================
rule getFaceOfTheGorgon
    inactive
    minInterval 31 //starts in cAge4
    group techsGreekMinorGodAge4
{
    int techID = cTechFaceoftheGorgon;
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
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 80))
        return;
    
    if ((woodSupply < 600) || (favorSupply < 45))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FaceOfTheGorgon", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 40);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting FaceOfTheGorgon");
        xsSetRuleMinIntervalSelf(300);
    }
}
