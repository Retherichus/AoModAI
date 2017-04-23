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
        if (ShowAiEcho == true) aiEcho("Getting FloodOfTheNile");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechSkinOfTheRhino) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SkinOfTheRhino", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSkinOfTheRhino);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SkinOfTheRhino");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechFeral) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Feral", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFeral);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Feral");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float goldSupply = kbResourceGet(cResourceGold);

    if ((kbGetAge() < cAge3 && goldSupply < 650) || (kbUnitCount(cMyID, cUnitTypeAnubite, cUnitStateAlive) < 1))
	return;
    if (kbGetTechStatus(cTechFeetoftheJackal) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FeetOfTheJackal", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFeetoftheJackal);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting FeetOfTheJackal");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float goldSupply = kbResourceGet(cResourceGold);

    if (kbGetAge() < cAge3 && goldSupply < 650)
	return;
    if (kbGetTechStatus(cTechNecropolis) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Necropolis", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechNecropolis);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Necropolis");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechAdzeofWepwawet) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("AdzeOfWepwawet", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAdzeofWepwawet);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting AdzeOfWepwawet");
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
        if (ShowAiEcho == true) aiEcho("Getting SacredCats");
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
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypeSphinx, cUnitStateAlive) < 1))
        return;
    if (kbGetTechStatus(cTechCriosphinx) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Criosphinx", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCriosphinx);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Criosphinx");
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
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypeSphinx, cUnitStateAlive) < 1))
        return;
    if (kbGetTechStatus(cTechHieracosphinx) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Hieracosphinx", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHieracosphinx);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Hieracosphinx");
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
        aiPlanSetDesiredPriority(x, 75);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Shaduf");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechSundriedMudBrick) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SundriedMudBrick", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSundriedMudBrick);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SundriedMudBrick");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechMedjay) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Medjay", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechMedjay);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Medjay");
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
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbUnitCount(cMyID, cUnitTypePetsuchos, cUnitStateAlive) < 1))
        return;
    if (kbGetTechStatus(cTechCrocodopolis) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Crocodopolis", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCrocodopolis);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Crocodopolis");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechBoneBow) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("BoneBow", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBoneBow);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting BoneBow");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechSlingsoftheSun) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SlingsOfTheSun", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSlingsoftheSun);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SlingsOfTheSun");
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
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (kbGetAge() < cAge4))
        return;
    if (kbGetTechStatus(cTechStonesofRedLinen) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("StonesOfRedLinen", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechStonesofRedLinen);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting StonesOfRedLinen");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechRamoftheWestWind) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RamOfTheWestWind", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRamoftheWestWind);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting RamOfTheWestWind");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechSpiritofMaat) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("SpiritOfMaat", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSpiritofMaat);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting SpiritOfMaat");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechFuneralRites) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FuneralRites", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFuneralRites);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting FuneralRites");
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechCityoftheDead) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("CityOfTheDead", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCityoftheDead);
        aiPlanSetDesiredPriority(x, 25);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting CityOfTheDead");
    }
}

//age4
//Horus

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
        if (ShowAiEcho == true) aiEcho("Getting AtefCrown");
    }
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
    if (kbGetTechStatus(cTechBookofThoth) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("BookofThoth", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBookofThoth);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting BookofThoth");
    }
}


