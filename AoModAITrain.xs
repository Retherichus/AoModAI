//AoModAITrain.xs
//This file contains all train rules
//by Loki_GdD

//==============================================================================
rule maintainTradeUnits
minInterval 8 //starts in cAge3
inactive
{
	
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
	if ((gTransportMap == true) && (SameAG(MarketLoc, mainBaseLocation) == false))
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
				}
                else if (((trainPlanBuildingID != -1) && (trainPlanBuildingID != gTradeMarketUnitID))
				|| ((kbUnitGetCurrentHitpoints(gTradeMarketUnitID) > 0) && (trainPlanBuildingID == -1)))
                {
                    aiPlanDestroy(trainPlanIndexID);
                    gResetTradeMarket = true;
				}
                else
                return;
			}
		}
	} 
	if ((IhaveAllies == true) && (NumTcs < 1))
	{
        vector unitLoc = kbUnitGetPosition(findUnit(cUnitTypeMarket));
	    NumTcs = NumUnitsOnAreaGroupByRel(false, kbAreaGroupGetIDByPosition(unitLoc), cUnitTypeAbstractSettlement, cPlayerRelationAlly);
    }
	int numIdleTrade = getNumUnits(tradeCartPUID, cUnitStateAlive, cActionIdle, cMyID);
	if ((NumTcs < 1) || (numIdleTrade > 3) || (cMyCiv == cCivNuwa) && (kbGetAge() < cAge3) && (numTradeUnits >=5)) // don't train caravans if you have no TC or if too many are idle.
    return;
    int tradeTargetPop = gMaxTradeCarts;
	if (tradeTargetPop <= 0)
	return;

	if ((cvMaxTradePop >= 0) && (tradeTargetPop > cvMaxTradePop))    // Stay under control variable limit
	tradeTargetPop = cvMaxTradePop;   
    
    if (numTradeUnits >= tradeTargetPop)
    return;
	
    string planName = "Trade unit "+kbGetProtoUnitName(tradeCartPUID)+" maintain";    
    int trainTradeUnitPlanID = aiPlanCreate(planName, cPlanTrain);
    if (trainTradeUnitPlanID < 0)
	return;
	
	aiPlanSetEconomy(trainTradeUnitPlanID, true);
    aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanUnitType, 0, tradeCartPUID);
    
	if ((numTradeUnits < tradeTargetPop - 3) && (tradeTargetPop > 4))
	aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanNumberToTrain, 0, 3);
	else
	aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanNumberToTrain, 0, 1);
    aiPlanSetBaseID(trainTradeUnitPlanID, mainBaseID);
    //Train at trade market if there is a trade market
    if (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) > 0)
	aiPlanSetVariableInt(trainTradeUnitPlanID, cTrainPlanBuildingID, 0, gTradeMarketUnitID);
    aiPlanSetDesiredPriority(trainTradeUnitPlanID, 96);
	aiPlanSetVariableBool(trainTradeUnitPlanID, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetActive(trainTradeUnitPlanID);
}

//==============================================================================
rule maintainAirScouts
minInterval 54 //starts in cAge1
inactive
{        
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
	
    if (xsGetTime() < 5*60*1000)
	return;
	
    xsSetRuleMinIntervalSelf(17);
    int numSettles = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    for (i=0; < numSettles)
    {
        int settleID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive, -1, cMyID);
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
			    if (gGoldGlutRatio > 1.5)
				numMercs = numberEnemyUnits;
			    if (numMercs > 12)
				numMercs = 12;
                int Mercs = createSimpleTrainPlan(cUnitTypeMercenary, numMercs, false, itsBase);
				addSDT(Mercs, 20);
				if ((gGoldGlutRatio > 1.5) && (aiRandInt(3) == 0))
				{
					int Cav = createSimpleTrainPlan(cUnitTypeMercenaryCavalry, 2, false, itsBase);
					addSDT(Cav, 20);
				}
			}
			xsSetRuleMinIntervalSelf(61);
		}
	}
}

//==============================================================================
rule trainMythUnit
minInterval 25 //starts in cAge2
inactive
{
	
    if (kbGetAge() < cAge3)
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
        if ((foodSupply > 400) && (goldSupply > 400))
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
	
    if (numMilitaryMythUnits >= 18)
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
    aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 5);
	else
    aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 2);
    aiPlanSetVariableBool(planID, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetDesiredPriority(planID, 100);
    aiPlanSetActive(planID);
}


//==============================================================================
rule hesperides //Watch for ownership of a hesperides tree, make driads if you own it.
minInterval 127 //starts in cAge2
inactive
{
	
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
minInterval 15 //starts in cAge3
inactive
{        
	
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
    if (CataMaintain != -1) 
	{
	    if ((woodSupply > 800) && (goldSupply > 800))
	    aiPlanSetVariableInt(CataMaintain, cTrainPlanNumberToMaintain, 0, 3);
		else
		aiPlanSetVariableInt(CataMaintain, cTrainPlanNumberToMaintain, 0, 1);
	}

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
		siegeUnitType1 = cUnitTypeBallista;
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
    if (siegeUnitType1BeingTrained == true)	
	return;
    
    int numSiegeUnitType1ToTrain = 2;
    if (kbGetAge() > cAge3)
	numSiegeUnitType1ToTrain = 4;
	
	if ((siegeUnitType1 == cUnitTypePortableRam) || (siegeUnitType1 == cUnitTypeFireSiphon)) // train some PortableRams or Siphons?
	numSiegeUnitType1ToTrain = 1;
	else if (siegeUnitType1 == cUnitTypeSiegeTower)
	numSiegeUnitType1ToTrain = 1;
    
	if ((numSiegeUnitType1 < numSiegeUnitType1ToTrain) && (siegeUnitType1BeingTrained == false))
    {
		if ((woodSupply > 300) && (goldSupply > 300))
		unitTypeToTrain = siegeUnitType1;
	}
    
    if (unitTypeToTrain == -1)
    {
        return;
	}
	
    string planName = "Siege unit "+kbGetProtoUnitName(unitTypeToTrain)+" maintain";    
    int trainSiegeUnitPlanID = aiPlanCreate(planName, cPlanTrain);
    if (trainSiegeUnitPlanID < 0)
	return;
	
    aiPlanSetMilitary(trainSiegeUnitPlanID, true);
    aiPlanSetVariableInt(trainSiegeUnitPlanID, cTrainPlanUnitType, 0, unitTypeToTrain);
	aiPlanSetVariableInt(trainSiegeUnitPlanID, cTrainPlanNumberToTrain, 0, 1);
    aiPlanSetVariableBool(trainSiegeUnitPlanID, cTrainPlanUseMultipleBuildings, 0, true);
    aiPlanSetBaseID(trainSiegeUnitPlanID, mainBaseID);
    aiPlanSetDesiredPriority(trainSiegeUnitPlanID, 100);
    aiPlanSetActive(trainSiegeUnitPlanID);
}
//==============================================================================
rule makeAtlanteanHeroes
minInterval 20 //starts in cAge1
inactive
{
	
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

	float GlutReq = 0.20;
	int HVills = kbUnitCount(cMyID, cUnitTypeVillagerAtlanteanHero, cUnitStateAlive);
	if (HVills > 0)
	GlutReq = 0.25;
	else if (HVills > 1)
	GlutReq = 0.45;

	if ((HVills < kbGetBuildLimit(cMyID, cUnitTypeVillagerAtlanteanHero)) && (gGlutRatio >= GlutReq))
	{
		int Vills = kbUnitCount(cMyID, cUnitTypeVillagerAtlantean, cUnitStateAlive);
		for (i = 0; < Vills)
		{
			int villagerID = findUnitByIndex(cUnitTypeVillagerAtlantean, i, cUnitStateAlive, -1, cMyID);
			if (kbUnitGetHealth(villagerID) > 0.9)
			{
				aiTaskUnitTransform(villagerID);
				break;
			}
		}
	}
	
    int unitIDToUse = -1;
    int numOracleHeroes = kbUnitCount(cMyID, cUnitTypeOracleHero, cUnitStateAlive);
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
	if (HVills > 0)
	numHeroes = numHeroes - HVills;
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
                    if (oracleID != -1)
                    {
                        if (kbUnitGetHealth(oracleID) > 0.9)
                        {
                            int planID = kbUnitGetPlanID(oracleID);
                            if (planID != -1)
                            {
                                int planType = aiPlanGetType(planID);
                                if ((planType == cPlanAttack) || ((planType == cPlanDefend) && (planID != gDefendPlanID)))
                                {
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
                return;
			}
		}
        else
        {
            if ((favorSupply < 60) || ((woodSupply < 350) || (foodSupply < 350) || (goldSupply < 350)))
            {
                return;
			}
		}
	}
	
    int planToUse = -1;
    int numUnitsInPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeHumanSoldier);
    if (numUnitsInPlan > 0)
	planToUse = gDefendPlanID;
	
    if (planToUse != -1)
    {
        int unitID = -1;
		for (i = 0; < numUnitsInPlan)
		{
			unitID = aiPlanGetUnitByIndex(planToUse, i);
			if (unitID != -1)
			{
				if (kbUnitIsType(unitID, cUnitTypeHumanSoldier) == true)
				{
					if ((kbUnitIsType(unitID, cUnitTypeMaceman) == false) && (kbUnitIsType(unitID, cUnitTypeTridentSoldier) == false))
					{
						if (kbUnitGetHealth(unitID) > 0.9)
						{
							unitIDToUse = unitID;
							break;
						}
					}
				}
			}
		}    
	}
	
    if (unitIDToUse != -1)
    aiTaskUnitTransform(unitIDToUse);
}

//================= EXTRA UNITS =================//
rule ExtraUnits
minInterval 7
group Forwarding
inactive
{
	int mainBaseID = kbBaseGetMainID(cMyID);
	int UnitType = cUnitTypeLogicalTypeBuildingsThatTrainMilitary;
	int Range = 45;
	int UnitToCounter = cUnitTypeLogicalTypeMilitaryUnitsAndBuildings;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
        int BaseID = kbUnitGetBaseID(unitID);	
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
		if ((enemyID != -1) && (BaseID != -1) && (BaseID != mainBaseID))
		taskMilUnitTrainAtBase(BaseID, 3, cUnitTypeAbstractSiegeWeapon);	
	}
}