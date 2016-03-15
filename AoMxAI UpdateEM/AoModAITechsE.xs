//AoModAITechsE.xs
//This file contains all Egyptian god specific techs.
//by Loki_GdD


//Egyptian
//Isis
//==============================================================================
// RULE: getFloodOfTheNile
//==============================================================================
rule getFloodOfTheNile
    inactive
    minInterval 23
{
    if (kbGetTechStatus(cTechFloodoftheNile) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FloodOfTheNile", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFloodoftheNile);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting FloodOfTheNile");
    }
}

//Ra
//==============================================================================
// RULE: getSkinOfTheRhino
//==============================================================================
rule getSkinOfTheRhino
    inactive
    minInterval 23
{
    if (kbGetTechStatus(cTechSkinOfTheRhino) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SkinOfTheRhino", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSkinOfTheRhino);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SkinOfTheRhino");
    }
}

//Set
//==============================================================================
// RULE: getFeral
//==============================================================================
rule getFeral
    inactive
    minInterval 23
{
    if (kbGetTechStatus(cTechFeral) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Feral", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFeral);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Feral");
    }
}

//age2 
//Anubis
//==============================================================================
// RULE: getFeetOfTheJackal
//==============================================================================
rule getFeetOfTheJackal
    inactive
    minInterval 27
    group Anubis
{
    if (kbGetTechStatus(cTechFeetoftheJackal) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FeetOfTheJackal", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFeetoftheJackal);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting FeetOfTheJackal");
    }
}

//==============================================================================
// RULE: getSerpentSpear
//==============================================================================
rule getSerpentSpear
    inactive
    minInterval 29
    group Anubis
{
    if (kbGetTechStatus(cTechSerpentSpear) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SerpentSpear", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSerpentSpear);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SerpentSpear");
    }
}

//==============================================================================
// RULE: getNecropolis
//==============================================================================
rule getNecropolis
    inactive
    minInterval 31
    group Anubis
{
    if (kbGetTechStatus(cTechNecropolis) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Necropolis", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechNecropolis);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Necropolis");
    }
}

//Bast
//==============================================================================
// RULE: getAdzeOfWepwawet
//==============================================================================
rule getAdzeOfWepwawet
    inactive
    minInterval 27
    group Bast
{
    if (kbGetTechStatus(cTechAdzeofWepwawet) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AdzeOfWepwawet", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAdzeofWepwawet);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting AdzeOfWepwawet");
    }
}

//==============================================================================
// RULE: getSacredCats
//==============================================================================
rule getSacredCats
    inactive
    minInterval 29
    group Bast
{
    if (kbGetTechStatus(cTechSacredCats) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SacredCats", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSacredCats);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SacredCats");
    }
}

//==============================================================================
// RULE: getCriosphinx
//==============================================================================
rule getCriosphinx
    inactive
    minInterval 31
    group Bast
{
    if (kbGetTechStatus(cTechCriosphinx) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Criosphinx", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCriosphinx);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Criosphinx");
    }
}

//==============================================================================
// RULE: getHieracosphinx
//==============================================================================
rule getHieracosphinx
    inactive
    minInterval 33
    group Bast
{
    if (kbGetTechStatus(cTechHieracosphinx) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Hieracosphinx", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHieracosphinx);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Hieracosphinx");
    }
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
    if (kbGetTechStatus(cTechShaduf) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Shaduf", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechShaduf);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Shaduf");
    }
}

//==============================================================================
// RULE: getScallopedAxe
//==============================================================================
rule getScallopedAxe
    inactive
    minInterval 29
    group Ptah
{
    if (kbGetTechStatus(cTechScallopedAxe) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ScallopedAxe", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechScallopedAxe);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting ScallopedAxe");
    }
}

//==============================================================================
// RULE: getLeatherFrameShield
//==============================================================================
rule getLeatherFrameShield
    inactive
    minInterval 31
    group Ptah
{
    if (kbGetTechStatus(cTechLeatherFrameShield) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LeatherFrameShield", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLeatherFrameShield);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting LeatherFrameShield");
    }
}

//==============================================================================
// RULE: getElectrumBullets
//==============================================================================
rule getElectrumBullets
    inactive
    minInterval 33
    group Ptah
{
    if (kbGetTechStatus(cTechElectrumBullets) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ElectrumBullets", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechElectrumBullets);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting ElectrumBullets");
    }
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
    if (kbGetTechStatus(cTechSundriedMudBrick) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SundriedMudBrick", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSundriedMudBrick);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SundriedMudBrick");
    }
}

//==============================================================================
// RULE: getMedjay
//==============================================================================
rule getMedjay
    inactive
    minInterval 29
    group Hathor
{
    if (kbGetTechStatus(cTechMedjay) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Medjay", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechMedjay);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Medjay");
    }
}

//==============================================================================
// RULE: getCrocodopolis
//==============================================================================
rule getCrocodopolis
    inactive
    minInterval 31
    group Hathor
{
    if (kbGetTechStatus(cTechCrocodopolis) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Crocodopolis", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCrocodopolis);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting Crocodopolis");
    }
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
    if (kbGetTechStatus(cTechBoneBow) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("BoneBow", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBoneBow);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting BoneBow");
    }
}

//==============================================================================
// RULE: getSlingsOfTheSun
//==============================================================================
rule getSlingsOfTheSun
    inactive
    minInterval 29
    group Sekhmet
{
    if (kbGetTechStatus(cTechSlingsoftheSun) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SlingsOfTheSun", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSlingsoftheSun);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SlingsOfTheSun");
    }
}

//==============================================================================
// RULE: getStonesOfRedLinen
//==============================================================================
rule getStonesOfRedLinen
    inactive
    minInterval 31
    group Sekhmet
{
    if (kbGetTechStatus(cTechStonesofRedLinen) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("StonesOfRedLinen", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechStonesofRedLinen);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting StonesOfRedLinen");
    }
}

//==============================================================================
// RULE: getRamOfTheWestWind
//==============================================================================
rule getRamOfTheWestWind
    inactive
    minInterval 33
    group Sekhmet
{
    if (kbGetTechStatus(cTechRamoftheWestWind) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RamOfTheWestWind", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRamoftheWestWind);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting RamOfTheWestWind");
    }
}

//Nephthys
//==============================================================================
// RULE: getSpiritOfMaat
//==============================================================================
rule getSpiritOfMaat
    inactive
    minInterval 27
    group Nephthys
{
    if (kbGetTechStatus(cTechSpiritofMaat) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SpiritOfMaat", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSpiritofMaat);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SpiritOfMaat");
    }
}

//==============================================================================
// RULE: getFuneralRites
//==============================================================================
rule getFuneralRites
    inactive
    minInterval 29
    group Nephthys
{
    if (kbGetTechStatus(cTechFuneralRites) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FuneralRites", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFuneralRites);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting FuneralRites");
    }
}

//==============================================================================
// RULE: getCityOfTheDead
//==============================================================================
rule getCityOfTheDead
    inactive
    minInterval 31
    group Nephthys
{
    if (kbGetTechStatus(cTechCityoftheDead) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("CityOfTheDead", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCityoftheDead);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting CityOfTheDead");
    }
}

//age4
//Horus
//==============================================================================
// RULE: getAxeOfVengeance
//==============================================================================
rule getAxeOfVengeance
    inactive
    minInterval 27
    group Horus
{
    if (kbGetTechStatus(cTechAxeofVengeance) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AxeOfVengeance", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAxeofVengeance);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting AxeOfVengeance");
    }
}

//==============================================================================
// RULE: getGreatestOfFifty
//==============================================================================
rule getGreatestOfFifty
    inactive
    minInterval 29
    group Horus
{
    if (kbGetTechStatus(cTechGreatestofFifty) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("GreatestOfFifty", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechGreatestofFifty);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting GreatestOfFifty");
    }
}

//==============================================================================
// RULE: getSpearOnTheHorizon
//==============================================================================
rule getSpearOnTheHorizon
    inactive
    minInterval 31
    group Horus
{
    if (kbGetTechStatus(cTechSpearontheHorizon) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SpearOnTheHorizon", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSpearontheHorizon);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting SpearOnTheHorizon");
    }
}

//Osiris
//==============================================================================
// RULE: getAtefCrown
//==============================================================================
rule getAtefCrown
    inactive
    minInterval 27
    group Osiris
{
    if (kbGetTechStatus(cTechAtefCrown) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AtefCrown", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAtefCrown);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting AtefCrown");
    }
}

//==============================================================================
// RULE: getDesertWind
//==============================================================================
rule getDesertWind
    inactive
    minInterval 29
    group Osiris
{
    if (kbGetTechStatus(cTechDesertWind) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DesertWind", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDesertWind);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting DesertWind");
    }
}

//==============================================================================
// RULE: getFuneralBarge
//==============================================================================
rule getFuneralBarge
    inactive
    minInterval 31
    group Osiris
{
    if (kbGetTechStatus(cTechFuneralBarge) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FuneralBarge", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFuneralBarge);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting FuneralBarge");
    }
}

//Thoth
//==============================================================================
// RULE: getValleyOfTheKings
//==============================================================================
rule getValleyOfTheKings
    inactive
    minInterval 27
    group Thoth
{
    if (kbGetTechStatus(cTechValleyoftheKings) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ValleyOfTheKings", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechValleyoftheKings);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting ValleyOfTheKings");
    }
}

//==============================================================================
// RULE: getTusksOfApedemak
//==============================================================================
rule getTusksOfApedemak
    inactive
    minInterval 29
    group Thoth
{
    if (kbGetTechStatus(cTechTusksofApedemak) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("TusksOfApedemak", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechTusksofApedemak);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        aiEcho("Getting TusksOfApedemak");
    }
}
