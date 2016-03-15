//AoModAITechsA.xs
//This file contains all Atlantean god specific techs.
//by Loki_GdD


//Atlantean
//Gaia
//==============================================================================
// RULE: getChannels
//==============================================================================
rule getChannels
    inactive
    minInterval 23
{
    if (kbGetTechStatus(cTechChannels) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Channels", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechChannels);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Channels");
    }
}

//Kronos
//==============================================================================
// RULE: getFocus
//==============================================================================
rule getFocus
    inactive
    minInterval 23
{
    if (kbGetTechStatus(cTechFocus) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Focus", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFocus);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Focus");
    }
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
    int techStatus = kbGetTechStatus(techID);
    if (techStatus > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
    }
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
        return;
    
    int numSkyPassages = kbUnitCount(cMyID, cUnitTypeSkyPassage, cUnitStateAlive);
    if (numSkyPassages < 1)
        return;
        
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if (((woodSupply < 250) || (favorSupply < 15)) && (numSkyPassages < 2))
        return;
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SafePassage", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        aiEcho("Getting SafePassage");
        xsSetRuleMinIntervalSelf(300);
    }
}


//age2
//Leto
//==============================================================================
// RULE: getHephaestusRevenge
//==============================================================================
rule getHephaestusRevenge
    inactive
    minInterval 27
    group Leto
{
    if (kbGetTechStatus(cTechHephaestusRevenge) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HephaestusRevenge", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHephaestusRevenge);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HephaestusRevenge");
    }
}

//==============================================================================
// RULE: getVolcanicForge
//==============================================================================
rule getVolcanicForge
    inactive
    minInterval 29
    group Leto
{
    if (kbGetTechStatus(cTechVolcanicForge) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("VolcanicForge", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechVolcanicForge);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting VolcanicForge");
    }
}

//Oceanus
//==============================================================================
// RULE: getBiteOfTheShark
//==============================================================================
rule getBiteOfTheShark
    inactive
    minInterval 27
    group Oceanus
{
    if (kbGetTechStatus(cTechBiteoftheShark) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("BiteOfTheShark", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBiteoftheShark);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting BiteOfTheShark");
    }
}

//==============================================================================
// RULE: getWeightlessMace
//==============================================================================
rule getWeightlessMace
    inactive
    minInterval 29
    group Oceanus
{
    if (kbGetTechStatus(cTechWeightlessMace) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("WeightlessMace", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechWeightlessMace);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting WeightlessMace");
    }
}

//Prometheus
//==============================================================================
// RULE: getHeartOfTheTitans
//==============================================================================
rule getHeartOfTheTitans
    inactive
    minInterval 27
    group Prometheus
{
    if (kbGetTechStatus(cTechHeartoftheTitans) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HeartOfTheTitans", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHeartoftheTitans);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HeartOfTheTitans");
    }
}

//==============================================================================
// RULE: getAlluvialClay
//==============================================================================
rule getAlluvialClay
    inactive
    minInterval 29
    group Prometheus
{
    if (kbGetTechStatus(cTechAlluvialClay) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AlluvialClay", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAlluvialClay);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting AlluvialClay");
    }
}


//age3
//Rheia
//==============================================================================
// RULE: getMailOfOrichalkos
//==============================================================================
rule getMailOfOrichalkos
    inactive
    minInterval 27
    group Rheia
{
    if (kbGetTechStatus(cTechMailofOrichalkos) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("MailOfOrichalkos", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechMailofOrichalkos);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting MailOfOrichalkos");
    }
}

//==============================================================================
// RULE: getHornsOfConsecration
//==============================================================================
rule getHornsOfConsecration
    inactive
    minInterval 29
    group Rheia
{
    if (kbGetTechStatus(cTechHornsofConsecration) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HornsOfConsecration", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHornsofConsecration);
        aiPlanSetDesiredPriority(x, 20);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HornsOfConsecration");
    }
}

//==============================================================================
// RULE: getRheiasGift
//==============================================================================
rule getRheiasGift
    inactive
    minInterval 31
    group Rheia
{
    if (kbGetTechStatus(cTechRheiasGift) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RheiasGift", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRheiasGift);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting RheiasGift");
    }
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
    if (kbGetTechStatus(cTechLemurianDescendants) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LemurianDescendants", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLemurianDescendants);
        aiPlanSetDesiredPriority(x, 20);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting LemurianDescendants");
    }
}

//==============================================================================
// RULE: getPoseidonsSecret
//==============================================================================
rule getPoseidonsSecret
    inactive
    minInterval 29
    group Theia
{
    if (kbGetTechStatus(cTechPoseidonsSecret) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("PoseidonsSecret", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechPoseidonsSecret);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting PoseidonsSecret");
    }
}

//==============================================================================
// RULE: getLanceOfStone
//==============================================================================
rule getLanceOfStone
    inactive
    minInterval 31
    group Theia
{
    if (kbGetTechStatus(cTechLanceofStone) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LanceOfStone", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLanceofStone);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting LanceOfStone");
    }
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
    if (kbGetTechStatus(cTechHeroicRenewal) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HeroicRenewal", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHeroicRenewal);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HeroicRenewal");
    }
}

//==============================================================================
// RULE: getGemino
//==============================================================================
rule getGemino
    inactive
    minInterval 29
    group Hyperion
{
    if (kbGetTechStatus(cTechGemino) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Gemino", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechGemino);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Gemino");
    }
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
    if (kbGetTechStatus(cTechTitanShield) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("TitanShield", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechTitanShield);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting TitanShield");
    }
}

//==============================================================================
// RULE: getEyesOfAtlas
//==============================================================================
rule getEyesOfAtlas
    inactive
    minInterval 29
    group Atlas
{
    if (kbGetTechStatus(cTechEyesofAtlas) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("EyesOfAtlas", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEyesofAtlas);
        aiPlanSetDesiredPriority(x, 20);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting EyesOfAtlas");
    }
}

//==============================================================================
// RULE: getIoGuardian
//==============================================================================
rule getIoGuardian
    inactive
    minInterval 31
    group Atlas
{
    if (kbGetTechStatus(cTechIoGuardian) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("IoGuardian", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechIoGuardian);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting IoGuardian");
    }
}


//Hekate
//==============================================================================
// RULE: getMythicRejuvenation
//==============================================================================
rule getMythicRejuvenation
    inactive
    minInterval 27
    group Hekate
{
    if (kbGetTechStatus(cTechMythicRejuvenation) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("MythicRejuvenation", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechMythicRejuvenation);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting MythicRejuvenation");
    }
}

//==============================================================================
// RULE: getCelerity
//==============================================================================
rule getCelerity
    inactive
    minInterval 29
    group Hekate
{
    if (kbGetTechStatus(cTechCelerity) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Celerity", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCelerity);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Celerity");
    }
}

//==============================================================================
// RULE: getAsperBlood
//==============================================================================
rule getAsperBlood
    inactive
    minInterval 31
    group Hekate
{
    if (kbGetTechStatus(cTechAsperBlood) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AsperBlood", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAsperBlood);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting AsperBlood");
    }
}


//Helios
//==============================================================================
// RULE: getHaloOfTheSun
//==============================================================================
rule getHaloOfTheSun
    inactive
    minInterval 27
    group Helios
{
    if (kbGetTechStatus(cTechHalooftheSun) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HaloOfTheSun", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHalooftheSun);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HaloOfTheSun");
    }
}

//==============================================================================
// RULE: getPetrified
//==============================================================================
rule getPetrified
    inactive
    minInterval 29
    group Helios
{
    if (kbGetTechStatus(cTechPetrified) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Petrified", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechPetrified);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Petrified");
    }
}