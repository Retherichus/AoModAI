//AoModAITrain.xs
//This file contains all train rules
//by Loki_GdD

//==============================================================================
rule maintainTradeUnits
minInterval 8 //starts in cAge3
inactive
{
    if (ShowAiEcho == true) aiEcho("maintainTradeUnits:");
	
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if ((numMarkets < 1) || (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 10*60*1000))
	return;

    int tradeCartPUID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0);
    int numTradeUnits = kbUnitCount(cMyID, tradeCartPUID, cUnitStateAliveOrBuilding);
    float foodSupply = kbResourceGet(cResourceFood);
    
	int NumTcs = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	vector MarketLoc = kbUnitGetPosition(gTradeMarketUnitID);
	if ((gTransportMap == true) && (kbAreaGroupGetIDByPosition(MarketLoc) != kbAreaGroupGetIDByPosition(mainBaseLocation)))
	return;

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
                    if (numTradeUnits < 2) 
                    {
                        if (foodSupply > 300)
                        {
                            aiTaskUnitTrain(gTradeMarketUnitID, tradeCartPUID);
                            if (ShowAiEcho == true) aiEcho("training a trade unit at our gTradeMarketUnitID: "+gTradeMarketUnitID);
						}
					}
                    return;
				}
			}
		}
	} 
	
	int numIdleTrade = getNumUnits(tradeCartPUID, cUnitStateAlive, cActionIdle, cMyID);
	if ((NumTcs < 1) || (numIdleTrade > 3) || (cMyCiv == cCivNuwa) && (kbGetAge() < cAge3) && (numTradeUnits >=3)) // don't train caravans if you have no TC or if too many are idle.
    return;
    int tradeTargetPop = gMaxTradeCarts;
   	if ((aiGetWorldDifficulty() == cDifficultyNightmare) || (kbGetAge() < cAge4) && (xsGetTime() < 30*60*1000))
    tradeTargetPop = gTitanTradeCarts;	
    if ((cvMaxTradePop >= 0) && (tradeTargetPop > cvMaxTradePop))    // Stay under control variable limit
	tradeTargetPop = cvMaxTradePop;
    int unitTypeToTrain = -1;
    
    if (NumTcs >=4)
	NumTcs = 5;
	if ((aiGetWorldDifficulty() == cDifficultyNightmare) && (NumTcs >= 2))
	NumTcs = 2;
	
    if ((NumTcs > 1) && (IhaveAllies == true) || (kbGetAge() > cAge3) && (foodSupply > 1500))
	tradeTargetPop = tradeTargetPop + 1 + NumTcs;
    
    if (numTradeUnits < tradeTargetPop)
    {
        if ((numTradeUnits < 3) && (foodSupply > 100))
		unitTypeToTrain = tradeCartPUID;
        else
        {
			if (foodSupply > 200)
			unitTypeToTrain = tradeCartPUID;
		}
	}
    if (unitTypeToTrain == -1)
    return;
	
    string planName = "Trade unit "+kbGetProtoUnitName(unitTypeToTrain)+" maintain";    
    int trainTradeUnitPlanID = aiPlanCreate(planName, cPlanTrain);
    if (trainTradeUnitPlanID < 0)
	return;
	
	aiPlanSetEconomy(trainTradeUnitPlanID, true);
    aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanUnitType, 0, unitTypeToTrain);
    
	if (numTradeUnits < tradeTargetPop - 3)
	aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanNumberToTrain, 0, 2);
	else
	aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanNumberToTrain, 0, 1);
    
    aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanFrequency, 0, 10);    
    aiPlanSetBaseID(trainTradeUnitPlanID, mainBaseID);
    //Train at trade market if there is a trade market
    if (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) > 0)
	aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanBuildingID, 0, gTradeMarketUnitID);
    aiPlanSetVariableBool(trainTradeUnitPlanID, cTrainPlanUseMultipleBuildings, 0, false);
    aiPlanSetDesiredPriority(trainTradeUnitPlanID, 96);
    aiPlanSetActive(trainTradeUnitPlanID);
}

//==============================================================================
rule maintainAirScouts
minInterval 54 //starts in cAge1
inactive
{        
    if (ShowAiEcho == true) aiEcho("maintainAirScouts:");
    static int AirScoutMaintain = -1;
    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    if ((numTemples < 1) || (kbGetAge() < cAge2))
	return;
	
    float foodSupply = kbResourceGet(cResourceFood);
	if (AirScoutMaintain == -1)
	{
		AirScoutMaintain = createSimpleMaintainPlan(gAirScout, 1, true, kbBaseGetMainID(cMyID));
		aiPlanSetDesiredPriority(AirScoutMaintain, 51);
	}
	
	if (AirScoutMaintain != -1)
	{
		if (foodSupply > 150)
		aiPlanSetVariableInt(AirScoutMaintain, cTrainPlanNumberToMaintain, 0, 1);
		else
		aiPlanSetVariableInt(AirScoutMaintain, cTrainPlanNumberToMaintain, 0, 0);
	}
}

//==============================================================================
rule ulfsarkMaintain
inactive
minInterval 15 //starts in cAge1
{
    if (ShowAiEcho == true) aiEcho("ulfsarkMaintain:");
	
    if (gUlfsarkMaintainPlanID >= 0)
	return;  // already exists
    gUlfsarkMaintainPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, 1, true, kbBaseGetMainID(cMyID));
    aiPlanSetDesiredPriority(gUlfsarkMaintainPlanID, 98); // Outrank civPopPlanID for villagers
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
minInterval 25 //starts in cAge2
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
	
    if (numMilitaryMythUnits > 0)
    {
        if ((kbGetTechStatus(cTechSecretsoftheTitans) >= cTechStatusResearching) && (favorSupply < 35) || (TitanAvailable == false) && (favorSupply < 35))
        {
            return;
		}
        else if ((kbGetAge() < cAge4) && (favorSupply < 30))
        {
            return;
		}
        else if ((favorSupply < 50) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (TitanAvailable == true))
        {
            return;
		}
	}
	
    if (numMilitaryMythUnits >= 8)
	return;
	
	
    static int planID = -1;
	
    int age2MythUnitID = -1;
    int age3MythUnitID = -1;
    int age4MythUnitID = -1;
    
    int number = -1;
    if (kbGetAge() >= cAge4)
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
	if (kbGetAge() < cAge4)
	{
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
	}
	else //In Mythic age only, this should give it a 75% chance of being an age 4 unit, and 25% for an age 3.. Never go for Age 2 ones.
	{
		if (aiRandInt(4) < 3)
		puid = age4MythUnitID;
		else
		puid = age3MythUnitID;
	}
    if (puid < 0)
	return;
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((puid == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == mainBaseID))
            {
                return;
			}
		}
	}
	
	
    string planName="Myth Train "+kbGetProtoUnitName(puid);
    planID=aiPlanCreate(planName, cPlanTrain);
    if (planID < 0)
	return;
	
    aiPlanSetMilitary(planID, true);
	aiPlanSetBaseID(planID, mainBaseID);
    aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
    if (puid == age4MythUnitID)
    aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 3);
	else
    aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 2);
    aiPlanSetDesiredPriority(planID, 100);
    aiPlanSetActive(planID);
}


//==============================================================================
rule hesperides //Watch for ownership of a hesperides tree, make driads if you own it.
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
            aiPlanDestroy(driadPlan);
            iHaveOne = false;
		}
	}
    else     // I don't think I have one...see if one has appeared, and set up maintain plan if it has
    {
        if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) > 0)   // I have one!
        {
            iHaveOne = true;
            driadPlan = createSimpleMaintainPlan(cUnitTypeDryad, 5, false, -1) ;
		}
	}
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
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);	
    
    if (cMyCulture == cCultureGreek)
    {
        siegeUnitType1 = cUnitTypePetrobolos;           
	}
    else if (cMyCulture == cCultureEgyptian)
    {
        if (kbGetAge() < cAge4)
		siegeUnitType1 = cUnitTypeSiegeTower;	
        else siegeUnitType1 = cUnitTypeCatapult;
	}
    else if (cMyCulture == cCultureNorse)
    {
        if (kbGetAge() < cAge4)
		siegeUnitType1 = cUnitTypePortableRam;
	    else
		{	
            if (aiRandInt(2) == 0)
		    siegeUnitType1 = cUnitTypeBallista;
			else siegeUnitType1 = cUnitTypePortableRam;
		}
	}
    else if (cMyCulture == cCultureChinese)
    {
        if (kbGetAge() < cAge4)
	    {
			if (cMyCiv == cCivShennong)
			siegeUnitType1 = cUnitTypeFireLanceShennong;
			else siegeUnitType1 = cUnitTypeFireLance;
		}	
		else 
		{	
			if (cMyCiv == cCivShennong)
			siegeUnitType1 = cUnitTypeSittingTigerShennong;
			else siegeUnitType1 = cUnitTypeSittingTiger;
		}
	}		
    else if (cMyCulture == cCultureAtlantean)
    {
        if (kbGetAge() < cAge4)
		siegeUnitType1 = cUnitTypeTridentSoldier;
        else
		{
			if (aiRandInt(2) == 0)
			siegeUnitType1 = cUnitTypeFireSiphon;
			else siegeUnitType1 = cUnitTypeOnager;
		}
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
                siegeUnitType1BeingTrained = true;
			}
		}
	}
    int numSiegeUnitType1 = kbUnitCount(cMyID, siegeUnitType1, cUnitStateAliveOrBuilding);
	
    if ((siegeUnitType1BeingTrained == true) && (ShouldIAgeUp() == false))
	{
		if ((numSiegeUnitType1 < 1) && (goldSupply > 450) && (woodSupply > 450) && (kbGetAge() >= cAge3))
		{
			int numSiegeWeaponBuildingsNearMBInR60 = getNumUnits(siegeWeaponBuildingType, cUnitStateAlive, -1, cMyID, mainBaseLocation, 100.0);
			if ((numSiegeWeaponBuildingsNearMBInR60 > 0) && (kbGetPop() >= kbGetPopCap()*0.90) && (kbGetPopCap() >= 115) && (kbGetPop() >= 115))
			{
				int siegeWeaponBuildingIDNearMBInR60 = findUnitByIndex(siegeWeaponBuildingType, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, 100.0);
				if (ShowAiEcho == true) aiEcho("siegeWeaponBuildingIDNearMBInR60: "+siegeWeaponBuildingIDNearMBInR60);
				if (siegeWeaponBuildingIDNearMBInR60 != -1)
				{
					//Try to train a siege weapon via aiTaskUnitTrain
					aiTaskUnitTrain(siegeWeaponBuildingIDNearMBInR60, siegeUnitType1);
					if ((goldSupply > 800) && (woodSupply > 800) && (kbGetAge() >= cAge4)) // add an extra one
					aiTaskUnitTrain(siegeWeaponBuildingIDNearMBInR60, siegeUnitType1);
					if (ShowAiEcho == true) aiEcho("Trying to train a siege weapon: "+siegeUnitType1+" at siegeWeaponBuildingIDNearMBInR60: "+siegeWeaponBuildingIDNearMBInR60);
				}
			}
		}		
		return;
	}
    
    int numSiegeUnitType1ToTrain = 2;
    if (kbGetAge() > cAge3)
	numSiegeUnitType1ToTrain = 4;
	
	if ((cMyCulture == cCultureNorse) && (siegeUnitType1 == cUnitTypePortableRam) || (cMyCulture == cCultureAtlantean) && (siegeUnitType1 == cUnitTypeFireSiphon)) // train some PortableRams or Siphons?
	numSiegeUnitType1ToTrain = 2;
    
	if ((numSiegeUnitType1 < numSiegeUnitType1ToTrain) && (siegeUnitType1BeingTrained == false))
    {
           if ((woodSupply > 300) && (goldSupply > 300))
		   unitTypeToTrain = siegeUnitType1;
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
	if ((kbGetAge() < cAge4) || (cMyCulture == cCultureAtlantean) || (cMyCulture == cCultureNorse))
	aiPlanSetVariableInt(trainSiegeUnitPlanID, cTrainPlanNumberToTrain, 0, 1);
    else
    aiPlanSetVariableInt(trainSiegeUnitPlanID, cTrainPlanNumberToTrain, 0, 2);
    aiPlanSetVariableBool(trainSiegeUnitPlanID, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetBaseID(trainSiegeUnitPlanID, mainBaseID);
    aiPlanSetDesiredPriority(trainSiegeUnitPlanID, 100);
    aiPlanSetActive(trainSiegeUnitPlanID);
    if (ShowAiEcho == true) aiEcho("Training a siege unit: "+kbGetProtoUnitName(unitTypeToTrain)+" at main base: "+mainBaseID);
}
//==============================================================================
rule makeAtlanteanHeroes
minInterval 20 //starts in cAge1
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
    
    if ((favorSupply < 10) || (woodSupply < 120) || (foodSupply < 150) || (goldSupply < 120))
    {
        return;
	}
    
    int unitIDToUse = -1;
    
    int numOracleHeroes = kbUnitCount(cMyID, cUnitTypeOracleHero, cUnitStateAlive);
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    if ((kbGetAge() < cAge2) || ((numHeroes < 1) && (xsGetTime() < 7*60*1000) && (kbGetAge() == cAge2)))
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
    
    if ((numHeroes >= 1) && (numHeroes <= currentPop / 15))
    {
        if (numHeroes <= 3)
        {
            if ((favorSupply < 20) || ((woodSupply < 200) || (foodSupply < 200) || (goldSupply < 200)))
            {
                if (ShowAiEcho == true) aiEcho("not enough resources, returning");
                return;
			}
		}
        else
        {
            if ((favorSupply < 60) || ((woodSupply < 350) || (foodSupply < 350) || (goldSupply < 350)))
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
}