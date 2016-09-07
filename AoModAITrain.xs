//AoModAITrain.xs
//This file contains all train rules
//by Loki_GdD

//==============================================================================
rule maintainTradeUnits
//    minInterval 23 //starts in cAge3
    minInterval 29 //starts in cAge3
    inactive
{
    if (ShowAiEcho == true) aiEcho("maintainTradeUnits:");
   
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if (numMarkets < 1)
        return;
    

	
	if (kbGetAge() < cAge3 && cMyCiv == cCivNuwa && IsRunTradeUnits1 == false)
	{
	gMaxTradeCarts = 3;
	IsRunTradeUnits1  = true;
    }
	
	if (kbGetAge() > cAge2 && cMyCiv == cCivNuwa && IsRunTradeUnits2 == false)
	{
	gMaxTradeCarts = 22;
	IsRunTradeUnits2  = true;
    }	
    int tradeCartPUID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0);
    int numTradeUnits = kbUnitCount(cMyID, tradeCartPUID, cUnitStateAlive);
    
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((tradeCartPUID == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                int trainPlanBuildingID = aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanBuildingID, 0);
                if ((kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0) && (trainPlanBuildingID != -1))
                {
                    aiPlanDestroy(trainPlanIndexID);
                    if (ShowAiEcho == true) aiEcho("destroying plan to train trade unit to remove trainPlanBuildingID");
                }
                else if (((trainPlanBuildingID != -1) && (trainPlanBuildingID != gTradeMarketUnitID))
                      || ((kbUnitGetCurrentHitpoints(gTradeMarketUnitID) > 0) && (trainPlanBuildingID == -1)))
                {
                    aiPlanDestroy(trainPlanIndexID);
                    if (ShowAiEcho == true) aiEcho("destroying plan to train trade unit to reset trainPlanBuildingID to gTradeMarketUnitID");
                    gResetTradeMarket = true;
                }
                else
                {
                    //if (ShowAiEcho == true) aiEcho("plan to train trade unit: "+kbGetProtoUnitName(tradeCartPUID)+" at main base: "+mainBaseID+" exists, returning");
                    if (numTradeUnits < 2) 
                    {
                        if (foodSupply > 300)
                        {
                            aiTaskUnitTrain(gTradeMarketUnitID, tradeCartPUID);
                            if (ShowAiEcho == true) aiEcho("trainig a trade unit at our gTradeMarketUnitID: "+gTradeMarketUnitID);
                        }
                    }
                    return;
                }
            }
        }
    } 
    
    int tradeTargetPop = gMaxTradeCarts;
    if ((cvMaxTradePop >= 0) && (tradeTargetPop > cvMaxTradePop))    // Stay under control variable limit
        tradeTargetPop = cvMaxTradePop;
		
	if (aiGetWorldDifficulty() == cDifficultyNightmare)
	{
    gMaxTradeCarts = gTitanTradeCarts;
	    if ((cvMaxTradePop >= 0) && (tradeTargetPop > cvMaxTradePop))    // Stay under control variable limit
        tradeTargetPop = cvMaxTradePop;
	}    
    int unitTypeToTrain = -1;
    
  
	
    if (woodSupply > 1500)
        tradeTargetPop = tradeTargetPop + 5;
    
    static bool firstRun = true;
    if (firstRun == true)
        unitTypeToTrain = tradeCartPUID;
    else if (numTradeUnits < tradeTargetPop)
    {
        if ((numTradeUnits < 5) && (foodSupply > 100))
            unitTypeToTrain = tradeCartPUID;
        else if ((numTradeUnits < 10) && (foodSupply > 150))
            unitTypeToTrain = tradeCartPUID;
        else
        {
            if (kbGetAge() == cAge3)
            {
                if  (foodSupply > 350)
                    unitTypeToTrain = tradeCartPUID;
            }
            else
            {
                if (foodSupply > 250)
                    unitTypeToTrain = tradeCartPUID;
            }
        }
    }
    
    if (unitTypeToTrain == -1)
    {
        //if (ShowAiEcho == true) aiEcho("trade unitTypeToTrain == -1, returning");
        return;
    }

    
    string planName = "Trade unit "+kbGetProtoUnitName(unitTypeToTrain)+" maintain";    
    int trainTradeUnitPlanID = aiPlanCreate(planName, cPlanTrain);
    if (trainTradeUnitPlanID < 0)
        return;
        
    aiPlanSetMilitary(trainTradeUnitPlanID, true);
    aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanUnitType, 0, unitTypeToTrain);
    if (firstRun == true)
    {
        aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanNumberToTrain, 0, 5);
        firstRun = false;
        aiTaskUnitTrain(gTradeMarketUnitID, unitTypeToTrain);
    }
    else
        aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanNumberToTrain, 0, 2);
    
    aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanFrequency, 0, 10);    
    aiPlanSetBaseID(trainTradeUnitPlanID, mainBaseID);
    //Train at trade market if there is a trade market
    if (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) > 0)
        aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanBuildingID, 0, gTradeMarketUnitID);
    aiPlanSetVariableBool(trainTradeUnitPlanID, cTrainPlanUseMultipleBuildings, 0, false);
    aiPlanSetDesiredPriority(trainTradeUnitPlanID, 100);
    aiPlanSetActive(trainTradeUnitPlanID);
}

//==============================================================================
rule maintainAirScouts
    minInterval 67 //starts in cAge1
    inactive
{        
    if (ShowAiEcho == true) aiEcho("maintainAirScouts:");
    
    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    if (numTemples < 1)
        return;

    float foodSupply = kbResourceGet(cResourceFood);
    
    if ((kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching) && (foodSupply < 500))
        return;
        
    int numAirScouts = kbUnitCount(cMyID, gAirScout, cUnitStateAlive);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((gAirScout == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                static bool alreadyInAge3 = false;
                if ((kbGetAge() == cAge3) && (alreadyInAge3 == false))
                {
                    aiPlanDestroy(trainPlanIndexID);
                    alreadyInAge3 = true;
                }
                
                if (kbGetAge() > cAge2)
                {
                    if (foodSupply > 400)
                    {
                        aiPlanSetVariableInt(trainPlanIndexID, cTrainPlanNumberToMaintain, 0, 1);
                    }
                    else if (foodSupply > 200)
                    {
                        aiPlanSetVariableInt(trainPlanIndexID, cTrainPlanNumberToMaintain, 0, 1);
                    }
                    else
                    {
                        aiPlanDestroy(trainPlanIndexID);
                    }
                }
                return;
            }
        }
    }

    int unitTypeToTrain = -1;
    
    if (numAirScouts < 2)
    {
        if (numAirScouts < 1)
        {
            if (foodSupply > 150)
                unitTypeToTrain = gAirScout;
        }
        else
        {
            if (foodSupply > 350)
                unitTypeToTrain = gAirScout;
        }
    }
    
    if (unitTypeToTrain == -1)
    {
        return;
    }

    
    int trainAirScoutPlanID = aiPlanCreate("air scout maintain", cPlanTrain);
    if (trainAirScoutPlanID < 0)
        return;
        
    aiPlanSetEconomy(trainAirScoutPlanID, true);
    aiPlanSetVariableInt(trainAirScoutPlanID, cTrainPlanUnitType, 0, unitTypeToTrain);
    if (kbGetAge() > cAge2)
    {
        if (foodSupply > 400)
        {
            aiPlanSetVariableInt(trainAirScoutPlanID, cTrainPlanNumberToMaintain, 0, 1);
        }
        else
        {
            aiPlanSetVariableInt(trainAirScoutPlanID, cTrainPlanNumberToMaintain, 0, 1);
        }
    }
    else
    {
        if (foodSupply > 350)
        {
            aiPlanSetVariableInt(trainAirScoutPlanID, cTrainPlanNumberToTrain, 0, 1);
        }
        else
        {
            aiPlanSetVariableInt(trainAirScoutPlanID, cTrainPlanNumberToTrain, 0, 1);
        }
    }
    aiPlanSetVariableInt(trainAirScoutPlanID, cTrainPlanFrequency, 0, 15);
    aiPlanSetBaseID(trainAirScoutPlanID, mainBaseID);
    aiPlanSetDesiredPriority(trainAirScoutPlanID, 100);
    aiPlanSetActive(trainAirScoutPlanID);
    if (ShowAiEcho == true) aiEcho("Training an air scout: "+kbGetProtoUnitName(unitTypeToTrain)+" at main base: "+mainBaseID);
}

//==============================================================================
rule trainDwarves
//    minInterval 113 //starts in cAge1
    minInterval 139 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("trainDwarves:");

    vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    float distance = 40.0;
    int numTemplesAtMainBase = getNumUnits(cUnitTypeTemple, cUnitStateAlive, -1, cMyID, location, distance);
    if (numTemplesAtMainBase < 1)
        return;
    
    gDwarfMaintainPlanID = createSimpleMaintainPlan(cUnitTypeDwarf, 2, true, -1);
    xsDisableSelf();
}

//==============================================================================
rule ulfsarkMaintain
    inactive
    minInterval 15 //starts in cAge1
{
    if (ShowAiEcho == true) aiEcho("ulfsarkMaintain:");
   
    if (gUlfsarkMaintainPlanID >= 0)
        return;  // already exists
    gUlfsarkMaintainPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, true, kbBaseGetMainID(cMyID));
    aiPlanSetDesiredPriority(gUlfsarkMaintainPlanID, 98); // Outrank civPopPlanID for villagers
    gUlfsarkMaintainMilPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, false, kbBaseGetMainID(cMyID));
    aiPlanSetDesiredPriority(gUlfsarkMaintainMilPlanID, 98); // Outrank civPopPlanID for villagers
    xsDisableSelf();
}

//==============================================================================
rule trainMercs
    minInterval 17 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("trainMercs:");

    if (xsGetTime() < 5*60*1000)
        return;

    xsSetRuleMinIntervalSelf(17);
    int settleQuery = kbUnitQueryCreate("SettleQuery");
    configQuery(settleQuery, cUnitTypeAbstractSettlement, -1, cUnitStateAlive, cMyID);
    kbUnitQueryResetResults(settleQuery);
    int numSettles = kbUnitQueryExecute(settleQuery);
    int settleID = -1;
    for (j=0; < numSettles)
    {
        settleID = kbUnitQueryGetResult(settleQuery, j);
        int itsBase = kbUnitGetBaseID(settleID);

        int numberEnemyUnits = kbBaseGetNumberUnits(cMyID, itsBase, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
        int numberAlliedUnits = kbBaseGetNumberUnits(cMyID, itsBase, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);
        int numberMyUnits = kbBaseGetNumberUnits(cMyID, itsBase, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);

        int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, itsBase);
        if (secondsUnderAttack > 10)
        {
            //Destroy the plan if there are twice as many enemies as my units plus allied units
            if ((numberEnemyUnits > 2 * (numberAlliedUnits + numberMyUnits)) && (numberEnemyUnits > 2))
            {
                int numMercs = numberEnemyUnits / 3;
                if (numMercs > 3)
                    numMercs = 3;
                if (ShowAiEcho == true) aiEcho("trainMercs: training="+numMercs+" Mercenaries.");
                for (i=0; < numMercs)
                {
                    aiTaskUnitTrain(settleID, cUnitTypeMercenary);
                }
                xsSetRuleMinIntervalSelf(61);
            }
        }
    }
}

//==============================================================================
rule trainMythUnit
    minInterval 35 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("trainMythUnit:");

    if ((xsGetTime() < 15*60*1000) && (kbGetAge() < cAge3))
        return;
    
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
  
    if (kbGetAge() > cAge3)
    {    
        if ((gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
            return;
    }
    else
    {
        if ((foodSupply > 600) && (goldSupply > 600))
            return;
    }
    
    int numMythUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeMythUnitNotTitan, cUnitStateAlive);
    int numNonMilitaryMythUnits = kbUnitCount(cMyID, cUnitTypePegasus, cUnitStateAlive);
    if (cMyCiv == cCivOdin)
        numNonMilitaryMythUnits = numNonMilitaryMythUnits + kbUnitCount(cMyID, cUnitTypeRaven, cUnitStateAlive);
    else if (cMyCulture == cCultureAtlantean)
        numNonMilitaryMythUnits = numNonMilitaryMythUnits + kbUnitCount(cMyID, cUnitTypeFlyingMedic, cUnitStateAlive);
    int numMilitaryMythUnits = numMythUnits - numNonMilitaryMythUnits;

    if ((numMilitaryMythUnits > 0) || (favorSupply < 40))
    {
        if ((kbGetTechStatus(cTechSecretsoftheTitans) >= cTechStatusResearching) && (favorSupply < 35))
        {
            //if (ShowAiEcho == true) aiEcho("trainMythUnit: returning as favor is below 35");
            return;
        }
        else if ((kbGetAge() < cAge4) && (favorSupply < 55))
        {
            //if (ShowAiEcho == true) aiEcho("trainMythUnit: returning as favor is below 55");
            return;
        }
        else if (favorSupply < 75)
        {
            //if (ShowAiEcho == true) aiEcho("trainMythUnit: returning as favor is below 75");
            return;
        }
    }

    if (numMilitaryMythUnits > 15)
    {
        //if (ShowAiEcho == true) aiEcho("trainMythUnit: returning as numMilitaryMythUnits > 15");
        return;
    }

    static int planID = -1;

    int age2MythUnitID = -1;
    int age3MythUnitID = -1;
    int age4MythUnitID = -1;
    
    int number = -1;
    if (kbGetAge() > cAge4)
        number = 3;
    else
        number = kbGetAge();
    
    if (cMyCulture == cCultureGreek)
    {
        // age2 myth units
        if (gAge2MinorGod == cTechAge2Ares)
            age2MythUnitID = cUnitTypeCyclops;
        else if (gAge2MinorGod == cTechAge2Athena)
            age2MythUnitID = cUnitTypeMinotaur;
        else if (gAge2MinorGod == cTechAge2Hermes)
            age2MythUnitID = cUnitTypeCentaur;
        
        // age3 myth units
        if (gAge3MinorGod == cTechAge3Aphrodite)
            age3MythUnitID = cUnitTypeNemeanLion;
        else if (gAge3MinorGod == cTechAge3Apollo)
            age3MythUnitID = cUnitTypeManticore;
        else if (gAge3MinorGod == cTechAge3Dionysos)
            age3MythUnitID = cUnitTypeHydra;
        
        // age4 myth units
        if (gAge4MinorGod == cTechAge4Artemis)
            age4MythUnitID = cUnitTypeChimera;
        else if (gAge4MinorGod == cTechAge4Hephaestus)
            age4MythUnitID = cUnitTypeColossus;
        else if (gAge4MinorGod == cTechAge4Hera)
            age4MythUnitID = cUnitTypeMedusa;
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        // age2 myth units
        if (gAge2MinorGod == cTechAge2Anubis)
            age2MythUnitID = cUnitTypeAnubite;
        else if (gAge2MinorGod == cTechAge2Bast)
            age2MythUnitID = cUnitTypeSphinx;
        else if (gAge2MinorGod == cTechAge2Ptah)
            age2MythUnitID = cUnitTypeWadjet;
        
        // age3 myth units
        if (gAge3MinorGod == cTechAge3Hathor)
            age3MythUnitID = cUnitTypePetsuchos;
        else if (gAge3MinorGod == cTechAge3Nephthys)
            age3MythUnitID = cUnitTypeScorpionMan;
        else if (gAge3MinorGod == cTechAge3Sekhmet)
            age3MythUnitID = cUnitTypeScarab;
        
        // age4 myth units
        if (gAge4MinorGod == cTechAge4Horus)
            age4MythUnitID = cUnitTypeAvenger;
        else if (gAge4MinorGod == cTechAge4Osiris)
            age4MythUnitID = cUnitTypeMummy;
        else if (gAge4MinorGod == cTechAge4Thoth)
            age4MythUnitID = cUnitTypePhoenix;
    }
    else if (cMyCulture == cCultureNorse)
    {
        // age2 myth units
        if (gAge2MinorGod == cTechAge2Forseti)
            age2MythUnitID = cUnitTypeTroll;
        else if (gAge2MinorGod == cTechAge2Freyja)
            age2MythUnitID = cUnitTypeValkyrie;
        else if (gAge2MinorGod == cTechAge2Heimdall)
            age2MythUnitID = cUnitTypeEinheriar;
        
        // age3 myth units
        if (gAge3MinorGod == cTechAge3Bragi)
            age3MythUnitID = cUnitTypeBattleBoar;
        else if (gAge3MinorGod == cTechAge3Njord)
            age3MythUnitID = cUnitTypeMountainGiant;
        else if (gAge3MinorGod == cTechAge3Skadi)
            age3MythUnitID = cUnitTypeFrostGiant;
        
        // age4 myth units
        if (gAge4MinorGod == cTechAge4Baldr)
            age4MythUnitID = cUnitTypeFireGiant;
        else if (gAge4MinorGod == cTechAge4Hel)
        {
            int chance = aiRandInt(3);
            if (chance == 0)
                age4MythUnitID = cUnitTypeFireGiant;
            else if (chance == 1)
                age4MythUnitID = cUnitTypeFrostGiant;
            else if (chance == 2)
                age4MythUnitID = cUnitTypeMountainGiant;
        }
        else if (gAge4MinorGod == cTechAge4Tyr)
            age4MythUnitID = cUnitTypeFenrisWolf;
    }
    else if (cMyCulture == cCultureAtlantean)
    {
        // age2 myth units
        if (gAge2MinorGod == cTechAge2Leto)
            age2MythUnitID = cUnitTypeAutomaton;
        else if (gAge2MinorGod == cTechAge2Prometheus)
            age2MythUnitID = cUnitTypePromethean;
        
        // age3 myth units
        if (gAge3MinorGod == cTechAge3Hyperion)
            age3MythUnitID = cUnitTypeSatyr;
        else if (gAge3MinorGod == cTechAge3Rheia)
            age3MythUnitID = cUnitTypeBehemoth;
        else if (gAge3MinorGod == cTechAge3Theia)
            age3MythUnitID = cUnitTypeStymphalianBird;
        
        // age4 myth units
        if (gAge4MinorGod == cTechAge4Atlas)
            age4MythUnitID = cUnitTypeArgus;
        else if (gAge4MinorGod == cTechAge4Helios)
            age4MythUnitID = cUnitTypeHekaGigantes;
        else if (gAge4MinorGod == cTechAge4Hekate)
            age4MythUnitID = cUnitTypeLampades;
    }
    else if (cMyCulture == cCultureChinese)
    {
        // age2 myth units
        if (gAge2MinorGod == cTechAge2Change)
            age2MythUnitID = cUnitTypeQilin;
        else if (gAge2MinorGod == cTechAge2Huangdi)
            age2MythUnitID = cUnitTypeTerracottaSoldier;
        else if (gAge2MinorGod == cTechAge2Sunwukong)
            age2MythUnitID = cUnitTypeMonkeyKing;
        
        // age3 myth units
        if (gAge3MinorGod == cTechAge3Dabogong)
            age3MythUnitID = cUnitTypePixiu;
        else if (gAge3MinorGod == cTechAge3Hebo)
            age3MythUnitID = cUnitTypeWarSalamander;
        else if (gAge3MinorGod == cTechAge3Zhongkui)
            age3MythUnitID = cUnitTypeJiangshi;
        
        // age4 myth units
        if (gAge4MinorGod == cTechAge4Aokuang)
            age4MythUnitID = cUnitTypeAzureDragon;
        else if (gAge4MinorGod == cTechAge4Xiwangmu)
            age4MythUnitID = cUnitTypeWhiteTiger;
        else if (gAge4MinorGod == cTechAge4Chongli)
            age4MythUnitID = cUnitTypeVermilionBird;
    }	
    
    if (number < 0)
    {
        if (ShowAiEcho == true) aiEcho(" strange: number < 0, returning!");
        return;
    }
    
    int puid = -1;
    int choice = aiRandInt(number);
    switch(choice)
    {
        case 0:
        {
            puid = age2MythUnitID;
            break;
        }
        case 1:
        {
            puid = age3MythUnitID;
            break;
        }
        case 2:
        {
            puid = age4MythUnitID;
            break;
        }
    }




	
    //if (ShowAiEcho == true) aiEcho("TrainMythUnit gets "+puid+": a "+kbGetProtoUnitName(puid));

    if (puid < 0)
        return;

    //In Mythic age only, this should give it a 75% chance of being an age 4 unit, and 25% for an age 3.. Never go for Age 2 ones.
	int choiceMythic = aiRandInt(4);
	if (kbGetAge() > cAge3)
	switch(choiceMythic)
    {
        case 0:
        {
            puid = age4MythUnitID;
            break;
        }
        case 1:
        {
            puid = age4MythUnitID;
            break;
        }
        case 2:
        {
            puid = age4MythUnitID;
            break;
        }
        case 3:
        {
            puid = age3MythUnitID;
            break;
        }		
    }
		
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((puid == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                //if (ShowAiEcho == true) aiEcho("plan to train myth unit: "+kbGetProtoUnitName(puid)+" at mainBaseID "+mainBaseID+" exists, returning");
                return;
            }
        }
    }


    string planName="Myth Train "+kbGetProtoUnitName(puid);
    planID=aiPlanCreate(planName, cPlanTrain);
    if (planID < 0)
        return;
        
    aiPlanSetMilitary(planID, true);
    aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
    if ((cMyCulture == cCultureAtlantean) && (puid == age2MythUnitID) && (puid != cUnitTypeFlyingMedic))
    {
        aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 2);
        aiPlanSetVariableInt(planID, cTrainPlanFrequency, 0, 30);
    }
    else
    {
        aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 1);
    }

    if (mainBaseID >= 0)
    {
        aiPlanSetBaseID(planID, mainBaseID);
        vector militaryGatherPoint = getMainBaseMilitaryGatherPoint();
        aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, militaryGatherPoint);
    }
    aiPlanSetDesiredPriority(planID, 100);
    aiPlanSetActive(planID);
    //if (ShowAiEcho == true) aiEcho("Training a myth unit: "+kbGetProtoUnitName(puid));
}


//==============================================================================
rule hesperides //Watch for ownership of a hesperides tree, make driads if you own it.  
//    minInterval 34 //starts in cAge1
    minInterval 127 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("hesperides:");

    static bool iHaveOne = false;
    static int driadPlan = -1;

    if (iHaveOne == true)   // I think I have one...verify, kill maintain plan if not.
    {
        if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) < 1)   // It's gone!
        {
            //if (ShowAiEcho == true) aiEcho("Lost the hesperides tree.");
            aiPlanDestroy(driadPlan);
            iHaveOne = false;
        }
    }
    else     // I don't think I have one...see if one has appeared, and set up maintain plan if it has
    {
        if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) > 0)   // I have one!
        {
            //if (ShowAiEcho == true) aiEcho("I have a hesperides tree.");
            iHaveOne = true;
            driadPlan = createSimpleMaintainPlan(cUnitTypeDryad, 5, false, -1) ;
        }
    }
}

//==============================================================================
rule maintainMilitaryTroops
    minInterval 17 //starts in cAge2
    inactive
{        
    if (ShowAiEcho == true) aiEcho("maintainMilitaryTroops:");

    int unitTypeToTrain = -1;
    int unitType1 = -1;
    int unitType2 = -1;
    int unitType3 = -1;
    
    if (cMyCulture == cCultureGreek)
    {
        unitType1 = cUnitTypeToxotes;
        unitType2 = cUnitTypeHippikon;
        unitType3 = cUnitTypeHoplite;
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        unitType1 = cUnitTypeSlinger;
        unitType2 = cUnitTypeAxeman;
        unitType3 = cUnitTypeSpearman;
    }
    else if (cMyCulture == cCultureNorse)
    {
        unitType1 = cUnitTypeThrowingAxeman;
        unitType2 = cUnitTypeRaidingCavalry;
        unitType3 = cUnitTypeUlfsark;
    }
    else if (cMyCulture == cCultureAtlantean)
    {
        unitType1 = cUnitTypeJavelinCavalry;
        unitType2 = cUnitTypeMaceman;
        unitType3 = cUnitTypeSwordsman;
    }
    else if (cMyCulture == cCultureChinese)
    {
        unitType1 = cUnitTypeChuKoNu;
        unitType2 = cUnitTypeHalberdier;
       //unitType3 = cUnitTypeScoutChinese;  // Not for now.
    }	
    
    bool unitType1BeingTrained = false;
    bool unitType2BeingTrained = false;
    bool unitType3BeingTrained = false;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((unitType1 == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                unitType1BeingTrained = true;
            }
            else if ((unitType2 == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                unitType2BeingTrained = true;
            }
            else if ((unitType3 == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                unitType3BeingTrained = true;
            }
        }
    }
    
    if ((unitType1BeingTrained == true) && (unitType2BeingTrained == true) && (unitType3BeingTrained == true))
    {
        //if (ShowAiEcho == true) aiEcho("all three unit types are being trained, returning");
        return;
    }
    
    
    int numUnitType1 = kbUnitCount(cMyID, unitType1, cUnitStateAlive);
    int numUnitType2 = kbUnitCount(cMyID, unitType2, cUnitStateAlive);
    int numUnitType3 = kbUnitCount(cMyID, unitType3, cUnitStateAlive);
    
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    if (numUnitType1 < gNumUnitType1ToTrain)
    {
        if  (unitType1BeingTrained == false)
        {
            if (numUnitType1 < 1)
                unitTypeToTrain = unitType1;
            else if ((numUnitType1 < 3) && ((woodSupply > 130) && (goldSupply > 100)))
                unitTypeToTrain = unitType1;
            else if ((woodSupply > 215) && (goldSupply > 144))
                unitTypeToTrain = unitType1;
        }
    }
    else if (numUnitType1 >= gNumUnitType1ToTrain)
    {
        if ((kbGetAge() == cAge2) && (gNumUnitType1ToTrain < 7))
            gNumUnitType1ToTrain = gNumUnitType1ToTrain + 1;
        else if ((kbGetAge() >= cAge3) && (gNumUnitType1ToTrain < 12))
            gNumUnitType1ToTrain = gNumUnitType1ToTrain + 1;
    }
    
    if (numUnitType2 < gNumUnitType2ToTrain)
    {
        if (unitType2BeingTrained == false)
        {
            if (numUnitType2 < 1)
                unitTypeToTrain = unitType2;
            else if ((numUnitType2 < 2) && ((foodSupply > 110) && (goldSupply > 120)))
                unitTypeToTrain = unitType2;
            else if ((foodSupply > 180) && (goldSupply > 195))
                unitTypeToTrain = unitType2;
        }
    }
    else if (numUnitType2 >= gNumUnitType2ToTrain)
    {
        if ((kbGetAge() == cAge2) && (gNumUnitType2ToTrain < 5))
            gNumUnitType2ToTrain = gNumUnitType2ToTrain + 1;
        else if ((kbGetAge() >= cAge3) && (gNumUnitType2ToTrain < 10))
            gNumUnitType2ToTrain = gNumUnitType2ToTrain + 1;
    }
    
    if (numUnitType3 < gNumUnitType3ToTrain)
    {
        if (unitType3BeingTrained == false)
        {
            if (numUnitType3 < 1)
                unitTypeToTrain = unitType3;
            else if ((numUnitType3 < 2) && ((foodSupply > 125) && (goldSupply > 80)))
                unitTypeToTrain = unitType3;
            else if ((foodSupply > 205) && (goldSupply > 120))
                unitTypeToTrain = unitType3;
        }
    }
    else if (numUnitType3 >= gNumUnitType3ToTrain)
    {
        if ((kbGetAge() == cAge2) && (gNumUnitType3ToTrain < 5))
            gNumUnitType3ToTrain = gNumUnitType3ToTrain + 1;
        else if ((kbGetAge() >= cAge3) && (gNumUnitType3ToTrain < 10))
            gNumUnitType3ToTrain = gNumUnitType3ToTrain + 1;
    }
    
    if (unitTypeToTrain == -1)
    {
        if (ShowAiEcho == true) aiEcho("military unitTypeToTrain == -1, returning");
        return;
    }

    string planName = "MilitaryUnit "+kbGetProtoUnitName(unitTypeToTrain)+" maintain";    
    int trainMilitaryUnitPlanID = aiPlanCreate(planName, cPlanTrain);
    if (trainMilitaryUnitPlanID < 0)
        return;
        
    aiPlanSetMilitary(trainMilitaryUnitPlanID, true);
    aiPlanSetVariableInt(trainMilitaryUnitPlanID, cTrainPlanUnitType, 0, unitTypeToTrain);
    aiPlanSetVariableInt(trainMilitaryUnitPlanID, cTrainPlanNumberToTrain, 0, 2);
    aiPlanSetVariableBool(trainMilitaryUnitPlanID, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetBaseID(trainMilitaryUnitPlanID, mainBaseID);
    aiPlanSetDesiredPriority(trainMilitaryUnitPlanID, 100);
    aiPlanSetActive(trainMilitaryUnitPlanID);
}

//==============================================================================
rule maintainSiegeUnits
    minInterval 23 //starts in cAge3
    inactive
{        
    if (ShowAiEcho == true) aiEcho("maintainSiegeUnits:");

    int siegeWeaponBuildingType = cUnitTypeAbstractFortress;
    if (cMyCulture == cCultureEgyptian)
        siegeWeaponBuildingType = cUnitTypeSiegeCamp;
    int numSiegeWeaponBuildings = kbUnitCount(cMyID, siegeWeaponBuildingType, cUnitStateAlive);
    if (numSiegeWeaponBuildings < 1)
        return;
    
    int unitTypeToTrain = -1;
    int siegeUnitType1 = -1;
    
    if (cMyCulture == cCultureGreek)
    {
        siegeUnitType1 = cUnitTypePetrobolos;
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        siegeUnitType1 = cUnitTypeCatapult;
    }
    else if (cMyCulture == cCultureNorse)
    {
        siegeUnitType1 = cUnitTypeBallista;
    }
    else if (cMyCulture == cCultureChinese)
    {
        siegeUnitType1 = cUnitTypeSittingTiger;
    }	
    else if (cMyCulture == cCultureAtlantean)
    {
        if (kbGetAge() < cAge4)
            siegeUnitType1 = cUnitTypeTridentSoldier;   //TODO: maybe try cUnitTypeChieroballista?
        else
            siegeUnitType1 = cUnitTypeFireSiphon;
    }
    
    bool siegeUnitType1BeingTrained = false;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((siegeUnitType1 == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                //if (ShowAiEcho == true) aiEcho("plan to train siegeUnitType1: "+kbGetProtoUnitName(siegeUnitType1)+" at main base: "+mainBaseID+" exists");
                siegeUnitType1BeingTrained = true;
            }
        }
    }
    
    if (siegeUnitType1BeingTrained == true)
    {
        //if (ShowAiEcho == true) aiEcho("siegeUnitType1 is being trained, returning");
        return;
    }
	
    int numSiegeUnitType1 = kbUnitCount(cMyID, siegeUnitType1, cUnitStateAliveOrBuilding);
    
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    int numSiegeUnitType1ToTrain = 3;
    if (kbGetAge() > cAge3)
        numSiegeUnitType1ToTrain = 5;
    if ((numSiegeUnitType1 < numSiegeUnitType1ToTrain) && (siegeUnitType1BeingTrained == false))
    {
        if ((cMyCulture == cCultureAtlantean) && (kbGetAge() < cAge4))
        {
            if (((numSiegeUnitType1 < 2) && (foodSupply > 100) && (goldSupply > 100)) || ((foodSupply > 160) && (goldSupply > 160)))
                unitTypeToTrain = siegeUnitType1;
        }
        else
        {
            if (((numSiegeUnitType1 < 1) && (woodSupply > 100) && (goldSupply > 100)) || ((woodSupply > 200) && (goldSupply > 200)))
                unitTypeToTrain = siegeUnitType1;
        }
    }
    
    if (unitTypeToTrain == -1)
    {
        if (ShowAiEcho == true) aiEcho("siege unitTypeToTrain == -1, returning");
        return;
    }

    string planName = "Siege unit "+kbGetProtoUnitName(unitTypeToTrain)+" maintain";    
    int trainSiegeUnitPlanID = aiPlanCreate(planName, cPlanTrain);
    if (trainSiegeUnitPlanID < 0)
        return;
        
    aiPlanSetMilitary(trainSiegeUnitPlanID, true);
    aiPlanSetVariableInt(trainSiegeUnitPlanID, cTrainPlanUnitType, 0, unitTypeToTrain);
    aiPlanSetVariableInt(trainSiegeUnitPlanID, cTrainPlanNumberToTrain, 0, 2);
    aiPlanSetVariableBool(trainSiegeUnitPlanID, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetBaseID(trainSiegeUnitPlanID, mainBaseID);
    aiPlanSetDesiredPriority(trainSiegeUnitPlanID, 100);
    aiPlanSetActive(trainSiegeUnitPlanID);
    if (ShowAiEcho == true) aiEcho("Training a siege unit: "+kbGetProtoUnitName(unitTypeToTrain)+" at main base: "+mainBaseID);
    
    if (numSiegeUnitType1 < 1)
    {
        int currentPop = kbGetPop();
        int currentPopCap = kbGetPopCap();
        if (ShowAiEcho == true) aiEcho("currentPop: "+currentPop);
        if (ShowAiEcho == true) aiEcho("currentPopCap: "+currentPopCap);
        int numSiegeWeaponBuildingsNearMBInR60 = getNumUnits(siegeWeaponBuildingType, cUnitStateAlive, -1, cMyID, mainBaseLocation, 60.0);
        if (ShowAiEcho == true) aiEcho("numSiegeWeaponBuildingsNearMBInR60: "+numSiegeWeaponBuildingsNearMBInR60);
        if ((numSiegeWeaponBuildingsNearMBInR60 > 0) && (currentPop >= currentPopCap - 4) && (currentPopCap > 100))
        {
            int siegeWeaponBuildingIDNearMBInR60 = findUnitByIndex(siegeWeaponBuildingType, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, 60.0);
            if (ShowAiEcho == true) aiEcho("siegeWeaponBuildingIDNearMBInR60: "+siegeWeaponBuildingIDNearMBInR60);
            if (siegeWeaponBuildingIDNearMBInR60 != -1)
            {
                //Try to train a siege weapon via aiTaskUnitTrain
                aiTaskUnitTrain(siegeWeaponBuildingIDNearMBInR60, unitTypeToTrain);
                if (ShowAiEcho == true) aiEcho("Trying to train a siege weapon: "+unitTypeToTrain+" at siegeWeaponBuildingIDNearMBInR60: "+siegeWeaponBuildingIDNearMBInR60);
            }
        }
    }
}

//==============================================================================
rule maintainHeroes
    minInterval 37 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("maintainHeroes:");
    
    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    if (numTemples < 1)
        return;
        
    if (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching)
        return;
        
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    int buildingIDToUse = -1;
    int hero1ID = -1;
    int hero2ID = -1;
    
    float requiredGold = 0.0;
    float requiredFood = 0.0;
    
    if (cMyCulture == cCultureGreek)
    {
        buildingIDToUse = getMainBaseUnitIDForPlayer(cMyID);
        requiredGold = 50.0;
        requiredFood = 100.0;
            
        if (cMyCiv == cCivZeus)
        {
            hero1ID = cUnitTypeHeroGreekJason;
            hero2ID = cUnitTypeHeroGreekOdysseus;
        }
        else if (cMyCiv == cCivPoseidon)
        {
            hero1ID = cUnitTypeHeroGreekTheseus;
            hero2ID = cUnitTypeHeroGreekHippolyta;
        }
        else if (cMyCiv == cCivHades)
        {
            hero1ID = cUnitTypeHeroGreekAjax;
            hero2ID = cUnitTypeHeroGreekChiron;
        }
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        buildingIDToUse = getMainBaseUnitIDForPlayer(cMyID);
        requiredGold = 100.0;
        hero1ID = cUnitTypePriest;
    }
    else if (cMyCulture == cCultureNorse)
    {
        //prefer temple near our mainbase
        buildingIDToUse = findUnitByIndex(cUnitTypeTemple, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, 50.0);
        if (buildingIDToUse == -1)  //if there's no temple near our mainbase, use a random temple
            buildingIDToUse = findUnit(cUnitTypeTemple, cUnitStateAlive, -1, cMyID);
        
        requiredGold = 40.0;
        requiredFood = 80.0;
        hero1ID =  cUnitTypeHeroNorse;
    }
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);

    int numHero1 = kbUnitCount(cMyID, hero1ID, cUnitStateAliveOrBuilding);
    int numHero2 = kbUnitCount(cMyID, hero2ID, cUnitStateAliveOrBuilding);
    int desiredNumHeroes = 1;
    if (cMyCulture == cCultureNorse)
        desiredNumHeroes = 2;
    if (numHero1 < desiredNumHeroes)
    {
        if ((goldSupply > requiredGold) && (foodSupply > requiredFood))
        {
            aiTaskUnitTrain(buildingIDToUse, hero1ID);
            if (ShowAiEcho == true) aiEcho("Attempting to train hero type:"+hero1ID+" at building with ID"+buildingIDToUse);
        }
    }
    if ((cMyCulture == cCultureGreek) && (kbGetAge() > cAge1))
    {
        if (numHero2 < 1)
        {
            if ((woodSupply > 200) && (favorSupply > 2))
            {
                aiTaskUnitTrain(buildingIDToUse, hero2ID);
                if (ShowAiEcho == true) aiEcho("Attempting to train hero type:"+hero2ID+" at building with ID"+buildingIDToUse);
            }
        }
    }
}

//==============================================================================
rule makeAtlanteanHeroes
    minInterval 37 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("makeAtlanteanHeroes:");
   
    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    if (numTemples < 1)
        return;
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    
    if ((favorSupply < 4) || (woodSupply < 70) || (foodSupply < 70) || (goldSupply < 70))
    {
        return;
    }
    
    int unitIDToUse = -1;
    
    int numOracleHeroes = kbUnitCount(cMyID, cUnitTypeOracleHero, cUnitStateAlive);
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    if ((kbGetAge() < cAge2) || ((numHeroes < 2) && (xsGetTime() < 12*60*1000)))
    {
        if (numOracleHeroes < 1)
        {
            int numOracles = kbUnitCount(cMyID, cUnitTypeOracleScout, cUnitStateAlive);
            if (numOracles > 0)
            {
                for (i = 0; < numOracles)
                {
                    int oracleID = findUnitByIndex(cUnitTypeOracleScout, i, cUnitStateAlive, -1, cMyID);
                    if (ShowAiEcho == true) aiEcho("oracleID: "+oracleID);
                    if (oracleID != -1)
                    {
                        if (kbUnitGetHealth(oracleID) > 0.9)
                        {
                            int planID = kbUnitGetPlanID(oracleID);
                            if (ShowAiEcho == true) aiEcho("planID: "+planID);
                            if (planID != -1)
                            {
                                int planType = aiPlanGetType(planID);
                                if (ShowAiEcho == true) aiEcho("planType: "+planType);
                                if ((planType == cPlanAttack) || ((planType == cPlanDefend) && (planID != gDefendPlanID)))
                                {
                                    if (ShowAiEcho == true) aiEcho("oracleID in cPlanAttack or cPlanDefend, skipping it");
                                    continue;
                                }
                            }
                            unitIDToUse = oracleID;
                            break;
                        }
                    }
                }
            }
        }
        else
        {
            return;
        }
    }

    
    int currentPop = kbGetPop();
    int numHumanSoldiers = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    int numMacemen = kbUnitCount(cMyID, cUnitTypeMaceman, cUnitStateAlive);
    int numDestroyers = kbUnitCount(cMyID, cUnitTypeTridentSoldier, cUnitStateAlive);
    int numPossibleUnits = numHumanSoldiers - numMacemen - numDestroyers;
    if (numPossibleUnits < 1)
    {
        return;
    }
    
    if ((numHeroes >= 2) && (numHeroes <= currentPop / 15))
    {
        if (numHeroes <= 4)
        {
            if ((favorSupply < 20) || ((woodSupply < 150) || (foodSupply < 150) || (goldSupply < 150)))
            {
                if (ShowAiEcho == true) aiEcho("not enough resources, returning");
                return;
            }
        }
        else
        {
            if ((favorSupply < 30) || ((woodSupply < 350) || (foodSupply < 350) || (goldSupply < 350)))
            {
                if (ShowAiEcho == true) aiEcho("not enough resources, returning");
                return;
            }
        }
    }

    int planToUse = -1;
    int numUnitsInPlan = 0;
    int numHumanSoldiersInDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeHumanSoldier);
    if (ShowAiEcho == true) aiEcho("numHumanSoldiersInDefendPlan: "+numHumanSoldiersInDefendPlan);
    if (numHumanSoldiersInDefendPlan > 0)
    {
        planToUse = gDefendPlanID;
        if (ShowAiEcho == true) aiEcho("planToUse = gDefendPlanID");
        numUnitsInPlan = aiPlanGetNumberUnits(planToUse, cUnitTypeUnit);
        if (ShowAiEcho == true) aiEcho("numUnitsInPlan: "+numUnitsInPlan);
    }
    if (ShowAiEcho == true) aiEcho("planToUse: "+planToUse);
    if (planToUse != -1)
    {
        int min = 0;
        int max = 9;
        int unitID = -1;
        
        static int flipFlop = 0;
        if (flipFlop == 0)
        {
            flipFlop = 1;
            if (numUnitsInPlan > max)
                numUnitsInPlan = max;
            for (i = 0; < numUnitsInPlan)
            {
                if (ShowAiEcho == true) aiEcho("i = "+i);
                unitID = aiPlanGetUnitByIndex(planToUse, i);
                if (unitID != -1)
                {
                    if (kbUnitIsType(unitID, cUnitTypeHumanSoldier) == true)
                    {
                        if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is a cUnitTypeHumanSoldier");
                        if ((kbUnitIsType(unitID, cUnitTypeMaceman) == false) && (kbUnitIsType(unitID, cUnitTypeTridentSoldier) == false))
                        {
                            if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is NOT a cUnitTypeMaceman and NOT a cUnitTypeTridentSoldier");
                            if (kbUnitGetHealth(unitID) > 0.9)
                            {
                                unitIDToUse = unitID;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is NOT a cUnitTypeHumanSoldier");
                    }
                }
            }    
        }
        else
        {
            flipFlop = 0;
            if (numUnitsInPlan > max)
                min = numUnitsInPlan - max;
            for (i = numUnitsInPlan - 1; >= min)
            {
                if (ShowAiEcho == true) aiEcho("i = "+i);
                unitID = aiPlanGetUnitByIndex(planToUse, i);
                if (unitID != -1)
                {
                    if (kbUnitIsType(unitID, cUnitTypeHumanSoldier) == true)
                    {
                        if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is a cUnitTypeHumanSoldier");
                        if ((kbUnitIsType(unitID, cUnitTypeMaceman) == false) && (kbUnitIsType(unitID, cUnitTypeTridentSoldier) == false))
                        {
                            if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is NOT a cUnitTypeMaceman and NOT a cUnitTypeTridentSoldier");
                            if (kbUnitGetHealth(unitID) > 0.9)
                            {
                                unitIDToUse = unitID;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is NOT a cUnitTypeHumanSoldier");
                    }
                }
            }
        }
    }

    if (unitIDToUse != -1)
    {
        aiTaskUnitTransform(unitIDToUse);
        if (ShowAiEcho == true) aiEcho("Attempting to transform unit with ID:"+unitIDToUse+" to a hero");
    }
    else
    {
        if (gDefendPlanID != -1)
        {
            aiPlanSetDesiredPriority(gDefendPlanID, 35);
            xsEnableRule("makeAtlanteanHeroesFallBack");
            if (ShowAiEcho == true) aiEcho("enabling the makeAtlanteanHeroesFallBack rule");
        }
    }
    
}

//==============================================================================
rule makeAtlanteanHeroesFallBack
    minInterval 10 //gets started in makeAtlanteanHeroes rule
    inactive
{
    if (ShowAiEcho == true) aiEcho("makeAtlanteanHeroesFallBack:");
    
    if (gDefendPlanID != -1)
    {
        int numHumanSoldiersInDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeHumanSoldier);
        if (ShowAiEcho == true) aiEcho("numHumanSoldiersInDefendPlan: "+numHumanSoldiersInDefendPlan);
        if (numHumanSoldiersInDefendPlan > 0)
        {
            int planToUse = gDefendPlanID;
            int numUnitsInPlan = aiPlanGetNumberUnits(planToUse, cUnitTypeUnit);
            if (ShowAiEcho == true) aiEcho("numUnitsInPlan: "+numUnitsInPlan);
            if (numUnitsInPlan > 0)
            {
                int unitIDToUse = -1;
                int min = 0;
                int max = 9;
                if (numUnitsInPlan > max)
                    min = numUnitsInPlan - max;
                for (i = numUnitsInPlan - 1; >= min)
                {
                    if (ShowAiEcho == true) aiEcho("i = "+i);
                    int unitID = aiPlanGetUnitByIndex(planToUse, i);
                    if (unitID != -1)
                    {
                        if (kbUnitIsType(unitID, cUnitTypeHumanSoldier) == true)
                        {
                            if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is a cUnitTypeHumanSoldier");
                            if ((kbUnitIsType(unitID, cUnitTypeMaceman) == false) && (kbUnitIsType(unitID, cUnitTypeTridentSoldier) == false))
                            {
                                if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is NOT a cUnitTypeMaceman and NOT a cUnitTypeTridentSoldier");
                                if (kbUnitGetHealth(unitID) > 0.9)
                                {
                                    unitIDToUse = unitID;
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" is NOT a cUnitTypeHumanSoldier");
                        }
                    }
                }
        
                if (unitIDToUse != -1)
                {
                    aiTaskUnitTransform(unitIDToUse);
                    if (ShowAiEcho == true) aiEcho("Attempting to transform unit with ID:"+unitIDToUse+" to a hero");
                }
            }
        }
    }
    aiPlanSetDesiredPriority(gDefendPlanID, 20);
    
    xsDisableSelf();
    
}
