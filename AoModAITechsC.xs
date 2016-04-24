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
    minInterval 23
{
    if (kbGetTechStatus(cTechAcupuncture) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Acupuncture", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAcupuncture);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Acupuncture");
    }
}

//FuXi
//==============================================================================
// RULE: getDomestication
//==============================================================================
rule getDomestication
    inactive
    minInterval 23
{
    if (kbGetTechStatus(cTechDomestication) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Domestication", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDomestication);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Domestication");
    }
}

//Shennong
//==============================================================================
// RULE: getWheelbarrow
//==============================================================================
rule getWheelbarrow
    inactive
    minInterval 23
{
    int techID = cTechWheelbarrow;
    int techStatus = kbGetTechStatus(techID);
	
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Wheelbarrow", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        aiEcho("Getting Wheelbarrow");
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
    if (kbGetTechStatus(cTechElixirofImmortality) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ElixirofImmortality", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechElixirofImmortality);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting ElixirofImmortality");
    }
}

//==============================================================================
// RULE: getHouyisBow
//==============================================================================
rule getHouyisBow
    inactive
    minInterval 29
    group Change
{
    if (kbGetTechStatus(cTechHouyisBow) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("VolcanicForge", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHouyisBow);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Houyis Bow");
    }
}

//==============================================================================
// RULE: getJadeRabbit
//==============================================================================
rule getJadeRabbit
    inactive
    minInterval 29
    group Change
{
    if (kbGetTechStatus(cTechJadeRabbit) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("VolcanicForge", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechJadeRabbit);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Jade Rabbit");
    }
}

//Sunwukong
//==============================================================================
// RULE: getGoldenBandedStaff
//==============================================================================
rule getGoldenBandedStaff
    inactive
    minInterval 27
    group Sunwukong
{
    if (kbGetTechStatus(cTechGoldenBandedStaff) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("GoldenBandedStaff", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechGoldenBandedStaff);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting GoldenBandedStaff");
    }
}

//==============================================================================
// RULE: getPaperTalisman
//==============================================================================
rule getPaperTalisman
    inactive
    minInterval 27
    group Sunwukong
{
    if (kbGetTechStatus(cTechPaperTalisman) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("PaperTalisman", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechPaperTalisman);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting PaperTalisman");
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
    if (kbGetTechStatus(cTechStoneArmor) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("StoneArmor", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechStoneArmor);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting StoneArmor");
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
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting FiveGrains");
    }
}

//==============================================================================
// RULE: getOracleBoneScript
//==============================================================================
rule getOracleBoneScript
    inactive
    minInterval 27
    group Huangdi
{
    if (kbGetTechStatus(cTechOracleBoneScript) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("OracleBoneScript", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechOracleBoneScript);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting OracleBoneScript");
    }
}


//Dabogong

//==============================================================================
// RULE: getLandlordSpirit
//==============================================================================
rule getLandlordSpirit
    inactive
    minInterval 27
    group Dabogong
{
    if (kbGetTechStatus(cTechLandlordSpirit) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LandlordSpirit", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLandlordSpirit);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting LandlordSpirit");
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
    if (kbGetTechStatus(cTechBurials) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Burials", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBurials);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Burials");
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
    if (kbGetTechStatus(cTechHouseAltars) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HouseAltars", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHouseAltars);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HouseAltars");
    }
}





// Zhongkui

//==============================================================================
// RULE: getLifeDrain
//==============================================================================
rule getLifeDrain
    inactive
    minInterval 27
    group Zhongkui
{
    if (kbGetTechStatus(cTechLifeDrain) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LifeDrain", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLifeDrain);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting LifeDrain");
    }
}


//==============================================================================
// RULE: getDemonSlayer
//==============================================================================
rule getDemonSlayer
    inactive
    minInterval 27
    group Zhongkui
{
    if (kbGetTechStatus(cTechDemonSlayer) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DemonSlayer", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDemonSlayer);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting DemonSlayer");
    }
}


//==============================================================================
// RULE: getUnbridledAnger
//==============================================================================
rule getUnbridledAnger
    inactive
    minInterval 27
    group Zhongkui
 {
    if (kbGetTechStatus(cTechUnbrideledAnger) == cTechStatusAvailable)
      {
          int x=-1;
        x = aiPlanCreate("UnbridledAnger", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechUnbrideledAnger);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Unbridled Anger");
      }
  }


// Hebo

//==============================================================================
// RULE: getSacrifices
//==============================================================================
rule getSacrifices
    inactive
    minInterval 27
    group Hebo
{
    if (kbGetTechStatus(cTechSacrifices) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Sacrifices", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSacrifices);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Sacrifices");
    }
}

//==============================================================================
// RULE: getLordoftheRiver
//==============================================================================
rule getLordoftheRiver
    inactive
    minInterval 27
    group Hebo
{
    if (kbGetTechStatus(cTechLordoftheRiver) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LordoftheRiver", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLordoftheRiver);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting LordoftheRiver");
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
    if (kbGetTechStatus(cTechRammedEarth) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RammedEarth", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRammedEarth);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting RammedEarth");
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
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting TigerSpirit");
    }
}

//==============================================================================
// RULE: getGoldenPeaches
//==============================================================================
rule getGoldenPeaches
    inactive
    minInterval 27
    group Xiwangmu
{
    if (kbGetTechStatus(cTechGoldenPeaches) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("GoldenPeaches", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechGoldenPeaches);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting GoldenPeaches");
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
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting CelestialPalace");
    }
}


// Chongli


//==============================================================================
// RULE: getHeavenlyFire
//==============================================================================
rule getHeavenlyFire
    inactive
    minInterval 27
    group Chongli
{
    if (kbGetTechStatus(cTechHeavenlyFire) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HeavenlyFire", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHeavenlyFire);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting HeavenlyFire");
    }
}

//==============================================================================
// RULE: getStirrup
//==============================================================================
rule getStirrup
    inactive
    minInterval 27
    group Chongli
{
    if (kbGetTechStatus(cTechStirrup) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Stirrup", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechStirrup);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Stirrup");
    }
}


//==============================================================================
// RULE: getAncientDestroyer
//==============================================================================
rule getAncientDestroyer
    inactive
    minInterval 27
    group Chongli
{
    if (kbGetTechStatus(cTechAncientDestroyer) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AncientDestroyer", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAncientDestroyer);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting AncientDestroyer");
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
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting NezhasDefeat");
    }
}

//==============================================================================
// RULE: getDragonScales
//==============================================================================
rule getDragonScales
    inactive
    minInterval 27
    group Aokuang
{
    if (kbGetTechStatus(cTechDragonScales) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DragonScales", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDragonScales);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting DragonScales");
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
    if (kbGetTechStatus(cTechEastSea) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("EastSea", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEastSea);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting EastSea");
    }
}
