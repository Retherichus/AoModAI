//==============================================================================
// AoMod AI
// AoModAI.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
// and... slightly modified by Retherichus, to ensure online play without desyncs.
// as well with some other fixes.. though! all credit still goes to Loki_GdD!
//
// This is the main ai file. If you want to use AoMod ai in your scenario,
// this would be the file you need to select. All other AoMod*.xs files are
// just helper files. They are no stand-alone ai files.
//==============================================================================

//==============================================================================
//The first part of this file is just a long list of global variables.  The
//'extern' keyword allows them to be used in any of the included files.  These
//are here to facilitate information sharing, etc.  The global variables are
//attempted to be named appropriately, but you should take a look at how they are
//used before making any assumptions about their actual utility.

//==============================================================================
//Map-Related Globals.
extern bool gWaterMap=false;              // Set true if fishing is likely to be good.
extern bool gTransportMap=false;          // Set true if transports are needed or very useful, i.e. island and shallow-chokepoint maps.

//==============================================================================
//Housing & PopCap.
extern int gHouseBuildLimit=-1;
extern int gHouseAvailablePopRebuild=10;     // Build a house when pop is within this amount of the current pop limit
extern int gHardEconomyPopCap=-1;            // Sets an absolute upper limit on the number of villagers maintained in the updateEM rules
extern int gEarlySettlementTarget = 3;       // How many age 1/2 settlements do we want?

//==============================================================================
//Econ Globals.
extern int   gGatherGoalPlanID=-1;
extern int   gCivPopPlanID=-1;
extern int   gNumBoatsToMaintain=6;       // Target number of fishing boats
extern bool	 gFarming=false;              // Set true when a farming plan is created, used to forecast farm resource needs.
extern bool  gFishing=false;              // Set true when a fishing plan is created, used to forecast fish boat wood demand
extern float gGoldForecast = 0.0;			// Forecasted demand over the next few minutes
extern float gWoodForecast = 0.0;
extern float gFoodForecast = 0.0;
extern int   gHerdPlanID = -1;            // Herds animals to base
extern float gGlutRatio = 0.0;            // 1.0 indicates all resources at 3 min forecast.  2.0 means all at least double.  Used to trim econ pop.
extern int   gLastAgeHandled = cAge1;     // Set to cAge2..cAge5 as the age handlers run. Used to detect age-ups granted via triggers and starting conditions, 


// Trade globals
extern int gMaxTradeCarts = 21;           // Max trade carts
extern int gTradePlanID = -1;
extern bool gExtraMarket = false;          // Used to indicate if an extra (non-trade) market has been requested
extern int gTradeMarketUnitID = -1;       // Used to identify the market being used in our trade plan.
extern vector gTradeMarketLocation = cInvalidVector; // location of our trade market
extern vector gTradeMarketDesiredLocation = cInvalidVector; // location, where we want to build our trade market.
extern int gExtraMarketUnitID = -1;       // Used to identify the extra market
extern bool gResetTradeMarket = false;


//==============================================================================
//Military Globals.
extern bool gBuildWalls = true;
extern int gWallPlanID = -1;
extern int gRushUPID=-1;            // Unit picker ID for age 2 (cAge2) armies.
extern int gLateUPID=-1;            // Unit picker for age 3/4 (cAge3 and cAge4).
extern int gNavalUPID=-1;
extern int gNumberBuildings=3;      // Number of buildings requested for late unit picker
extern int gNavalAttackGoalID=-1;
extern int gRushGoalID=-1;
extern int gLandAttackGoalID=-1;
extern int gIdleAttackGID=-1;       // Attack goal, inactive, used to maintain mil pop after rush and/or before age 3 (cAge3) attack.
extern int gDefendPlanID = -1;      // Uses military units to defend main base while waiting to mass an attack army
extern int gWonderDefendPlan = -1;     // Uber-plan to defend my wonder
extern int gEnemyWonderDefendPlan = -1;   // Uber-uber-plan to attack or defend other wonder
extern int gObeliskClearingPlanID = -1;   // Small attack plan used to remove enemy obelisks
extern int gTargetNavySize = 0;     // Set periodically based on difficulty, enemy navy/fish boat count. Units, not pop slots.

//==============================================================================
//Minor Gods.
extern int gAge2MinorGod = -1;
extern int gAge3MinorGod = -1;
extern int gAge4MinorGod = -1;

//==============================================================================
//God Powers
extern int gAge1GodPowerID = -1;
extern int gAge2GodPowerID = -1;
extern int gAge3GodPowerID = -1;
extern int gAge4GodPowerID = -1;
extern int gAge5GodPowerID = -1;
extern int gAge1GodPowerPlanID = -1;
extern int gAge2GodPowerPlanID = -1;
extern int gAge3GodPowerPlanID = -1;
extern int gAge4GodPowerPlanID = -1;
extern int gAge5GodPowerPlanID = -1;
extern int gTownDefenseGodPowerPlanID = -1;
extern int gTownDefenseEvalModel = -1;
extern int gTownDefensePlayerID = -1;
extern int gTownDefenseTargetingModel = -1;
extern vector gTownDefenseLocation = cInvalidVector;

extern int gUnbuildPlanID = -1;
extern int gPlaceTitanGatePlanID = -1;

extern int gCeaseFirePlanID=-1;
extern int gSentinelPlanID=-1;
extern int gDwarvenMinePlanID = -1;
extern int gRagnorokPlanID = -1;
extern int gHeavyGPTechID = -1;
extern int gHeavyGPPlanID = -1;
extern int gGaiaForestPlanID = -1;
extern int gHesperidesPlanID = -1;


//==============================================================================
//Special Case Stuff
extern int gLandScout = -1;
extern int gAirScout = -1;
extern int gWaterScout = -1;

extern int gMaintainNumberLandScouts = 1;
extern int gMaintainNumberAirScouts = 1;
extern int gMaintainNumberWaterScouts = 1;

extern int gEmpowerPlanID = -1;
//Ra
extern int eOsiris = -1;
extern int Pempowermarket = -1;
extern int APlanID = -1;
extern int BPlanID = -1;
extern int CPlanID = -1;
//Ra end
extern int gRelicGatherPlanID = -1;
extern int gMaintainWaterXPortPlanID=-1;
extern int gResignType = -1;
extern int gVinlandsagaTransportExplorePlanID=-1;
extern int gVinlandsagaInitialBaseID=-1;
extern int gNomadExplorePlanID1=-1;
extern int gNomadExplorePlanID2=-1;
extern int gNomadExplorePlanID3=-1;
extern int gNomadSettlementBuildPlanID=-1;
extern int gKOTHPlentyUnitID=-1;
extern int gLandExplorePlanID=-1;
extern int gFarmBaseID = -1;
extern int gUlfsarkMaintainPlanID = -1;   // Used to maintain a small pop of ulfsarks for building

//New globals
extern int gGatherRelicType = -1;

extern bool gBuildWallsAtMainBase = true;

extern vector gBackAreaLocation = cInvalidVector;
extern vector gHouseAreaLocation = cInvalidVector;
extern int gBackAreaID = -1;
extern int gHouseAreaID = -1;
extern bool gResetWallPlans = false;

extern float gMainBaseAreaWallRadius = 28;
extern float gSecondaryMainBaseAreaWallRadius = 42;

extern int gMainBaseAreaWallTeam1PlanID = -1;
extern int gMainBaseAreaWallTeam2PlanID = -1;

extern int gOtherBaseRingWallTeam1PlanID = -1;

//extern float gOtherBaseWallRadius = 17.0;
extern float gOtherBaseWallRadius = 24.0;

extern int gBuildBuilding1AtOtherBasePlanID = -1;

extern int gMBDefPlan1ID = -1;
extern int gOtherBase1ID = -1;			// globals for defend plans for other bases
extern int gOtherBase2ID = -1;
extern int gOtherBase3ID = -1;
extern int gOtherBase4ID = -1;
extern int gOtherBase1UnitID = -1;
extern int gOtherBase2UnitID = -1;
extern int gOtherBase3UnitID = -1;
extern int gOtherBase4UnitID = -1;
extern int gOtherBase1DefPlanID = -1;
extern int gOtherBase2DefPlanID = -1;
extern int gOtherBase3DefPlanID = -1;
extern int gOtherBase4DefPlanID = -1;
extern int gOtherBase1RingWallTeamPlanID = -1;
extern int gOtherBase2RingWallTeamPlanID = -1;
extern int gOtherBase3RingWallTeamPlanID = -1;
extern int gOtherBase4RingWallTeamPlanID = -1;

extern int gHero1MaintainPlan = -1;
extern int gHero2MaintainPlan = -1;
extern int gHero3MaintainPlan = -1;
extern int gHero4MaintainPlan = -1;

extern int gEnemySettlementAttPlanID = -1;
extern int gEnemySettlementAttPlanTargetUnitID = -1;
extern vector gEnemySettlementAttPlanLastAttPoint = cInvalidVector;
extern vector gSettlementPosDefPlanDefPoint = cInvalidVector;
extern int gSettlementPosDefPlanID = -1;

extern int gRaidingPartyAttackID = -1;
extern int gRaidingPartyTargetUnitID = -1;
extern vector gRaidingPartyLastTargetLocation = cInvalidVector;
extern vector gRaidingPartyLastMarketLocation = cInvalidVector;

extern int gRushCount = 0;
extern int gNumRushAttacks = 0;
extern int gRushSize = 0;
extern int gFirstRushSize = 0;
extern int gRushAttackCount = 0; 
extern int gLandAttackPlanID = -1; 

extern int gRandomAttackPlanID = -1;
extern int gRandomAttackTargetUnitID = -1;
extern vector gRandomAttackLastTargetLocation = cInvalidVector;
extern vector gRandomAttackLastMarketLocation = cInvalidVector;

extern int gDockBaseID = -1;
extern int gWaterExploreID = -1;
extern int gFishPlanID = -1;
extern int gDockToUse = -1;

extern int gResearchGranaryID = -1;

extern int gAirScout1PlanID = -1;
extern int gAirScout2PlanID = -1;

extern vector gBaseUnderAttackLocation = cInvalidVector;
extern int gBaseUnderAttackID = -1;
extern int gBaseUnderAttackDefPlanID = -1;

extern bool gHuntersExist = false;

extern int gAlliedBaseDefPlanID = -1;
//New globals end

//==============================================================================
//Base Globals.
extern int gGoldBaseID=-1;          // Base used for gathering gold, although main base is used if gold exists there
extern int gWoodBaseID=-1;          // Ditto for wood
extern float gMaximumBaseResourceDistance = 85.0;

//==============================================================================
//Age Progression Plan IDs.
extern int gAge2ProgressionPlanID = -1;
extern int gAge3ProgressionPlanID = -1;
extern int gAge4ProgressionPlanID = -1;

//==============================================================================
//Forward declarations.
mutable void setOverrides(void) {}        // Used in loader file to override init parameters, called at end of main()
mutable void setParameters(void) {}       // Used in loader file to set control parameters, called at start of main()
mutable void setMilitaryUnitPrefs(int primaryType = -1, int secondaryType = -1, int tertiaryType = -1) {}   // Used by loader to override unitPicker choices
mutable void age2Handler(int age=1) { }
mutable void age3Handler(int age=2) { }
mutable void age4Handler(int age=3) { }
mutable int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1) { }
mutable bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1) { }
mutable void buildHandler(int protoID=-1) { }
mutable void gpHandler(int powerID=-1)    { }
mutable int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, 
int builderUnitTypeID=-1, bool autoUpdate=true, int pri=100) { }
mutable int getSoftPopCap(void) {}
mutable void unbuildHandler() { }
mutable void age5Handler(int age=4) { }
mutable int createTransportPlan(string name="BUG", int startAreaID=-1, int goalAreaID=-1,
bool persistent=false, int transportPUID=-1, int pri=-1, int baseID=-1) {}
mutable int createSimpleAttackGoal(string name="BUG", int attackPlayerID=-1,
int unitPickerID=-1, int repeat=-1, int minAge=-1, int maxAge=-1,
int baseID=-1, bool allowRetreat=false) {}
mutable bool mapPreventsHousesAtTowers()    { }

//TODO: Check if they are really necessary!
mutable void findTownDefenseGP(int baseID=-1) { }
mutable void releaseTownDefenseGP() { }
mutable bool mapRestrictsMarketAttack() { }
mutable void pullBackUnits(int planID = -1, vector retreatPosition = cInvalidVector) { }

//==============================================================================
//Basics Include.
include "AoModAIBasics.xs";

// Placeholder Reth
mutable void initRethlAge1() {}
include "AoModAiExtra.xs";
//==============================================================================

//==============================================================================
//BuildRules Include.
include "AoModAIBuild.xs";

//==============================================================================
//Economy Include.
include "AoModAIEcon.xs";

//==============================================================================
//God Powers Include.
include "AoModAIGPs.xs";

//==============================================================================
//Map Specifics Include.
include "AoModAIMapSpec.xs";

//==============================================================================
//Military Include.
include "AoModAIMil.xs";

//==============================================================================
//Naval Include.
include "AoModAINaval.xs";

//==============================================================================
//Personality Include.
include "AoModAIPers.xs";

//==============================================================================
//Progress Include.
include "AoModAIProgr.xs";

//==============================================================================
//TechRules Include.
include "AoModAITechs.xs";

//==============================================================================
//trainRules Include.
include "AoModAITrain.xs";

//==============================================================================
rule updatePlayerToAttack   //Updates the player we should be attacking.
minInterval 27 //starts in cAge1
inactive
{
    static int lastTargetPlayerIDSaveTime = -1;
	static int IndexIncreaseTime = -1;
    static int lastTargetPlayerID = -1;
    static int randNum = 0;
    static bool increaseStartIndex = false;
	if (IndexIncreaseTime == -1)			
	IndexIncreaseTime = xsGetTime();
	
	if (ChangeMHP == true)
	{
		if (xsGetTime() > MHPTime + 1*60*1000)
		{
			ChangeMHP = false;
			//aiEcho("Setting MHP to false");
		}
		return;
	}
	
    if (ShowAiEcho == true) aiEcho("updatePlayerToAttack:");
    //Determine a random start index for our hate loop.
    static int startIndex = -1;
    if ((startIndex < 0) || (xsGetTime() > lastTargetPlayerIDSaveTime + (10 + randNum)*60*1000) && (aiRandInt(5) < 1))
    {
        startIndex = aiRandInt(cNumberPlayers);
        if (ShowAiEcho == true) aiEcho("getting new random startIndex. startIndex is now: "+startIndex);
	}
	
    //Find the "first" enemy player that's still in the game.  This will be the
    //script's recommendation for who we should attack.
    int comparePlayerID = -1;
    for (i = 0; < cNumberPlayers)
    {
        //If we're past the end of our players, go back to the start.
        int actualIndex = i + startIndex;
        if (actualIndex >= cNumberPlayers)
		actualIndex = actualIndex - cNumberPlayers;
        if (actualIndex <= 0)
		continue;
        if ((kbIsPlayerEnemy(actualIndex) == true) &&
		(kbIsPlayerResigned(actualIndex) == false) &&
		(kbHasPlayerLost(actualIndex) == false))
        {
            comparePlayerID = actualIndex;
            break;
		}
	}
	
    //Pass the comparePlayerID into the AI to see what he thinks.  He'll take care
    //of modifying the player in the event of wonders, etc.
    int actualPlayerID = -1;
	
    if (cvPlayerToAttack == -1)
	actualPlayerID = aiCalculateMostHatedPlayerID(comparePlayerID);
    else
	actualPlayerID = cvPlayerToAttack;
    
    if (actualPlayerID != lastTargetPlayerID)
    {
        lastTargetPlayerID = actualPlayerID;
        lastTargetPlayerIDSaveTime = xsGetTime();
        if (ShowAiEcho == true) aiEcho("lastTargetPlayerID: "+lastTargetPlayerID);
        if (ShowAiEcho == true) aiEcho("lastTargetPlayerIDSaveTime: "+lastTargetPlayerIDSaveTime);
        randNum = aiRandInt(5);
	}
	
    if (actualPlayerID != -1)
    {
        //Default us off.
        aiSetMostHatedPlayerID(actualPlayerID);
        if (ShowAiEcho == true) aiEcho("most hated playerID = "+actualPlayerID);
	}
	if (AoModAllies == true)
	{ 
		if (aiGetCaptainPlayerID(cMyID) != cMyID)
		return;
		MessageRel(cPlayerRelationAlly, AttackTarget, aiGetMostHatedPlayerID());
	}	 
}

//==============================================================================
rule checkEscrow    //Verify that escrow totals and real inventory are in sync
minInterval 6 //starts in cAge1
active
{
    if (ShowAiEcho == true) aiEcho("checkEscrow:");
	
    static int failCount = 0;
    static bool initialResetDone = false;
    if (initialResetDone == false)
    {
        initialResetDone = true;
        kbEscrowAllocateCurrentResources();
        return;
	}	
	
    bool fishingReset = false;    // Special reset in first 5 minutes for wood imbalance while fishing
	// (Every fishing boat trained gets double-billed.)
    bool needReset = false;
    int res = -1;
    for (res = 0; < 3)
    {
        int escrowQty = -1;
        int actualQty = -1;
        int delta = -1;
        escrowQty = kbEscrowGetAmount(cEconomyEscrowID, res);
        escrowQty = escrowQty + kbEscrowGetAmount(cMilitaryEscrowID, res);
        escrowQty = escrowQty + kbEscrowGetAmount(cRootEscrowID, res);
        actualQty = kbResourceGet(res);
        delta = actualQty - escrowQty;
        if (delta < 0)
		delta = delta * -1;
        if ( (delta > 20) && (delta > actualQty/5) ) // Off by at least 20, and 20%
        {
            needReset = true;
            if (res == cResourceGold)
			if (ShowAiEcho == true) aiEcho("Gold imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
            if (res == cResourceWood)
            {
                if (ShowAiEcho == true) aiEcho("Wood imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
                if ( (gFishing == true) && (xsGetTime()<(8*60*1000)) )
				fishingReset = true; // We're fishing, it's in the first 8 min, and wood is off.
			}
            if (res == cResourceFood)
			if (ShowAiEcho == true) aiEcho("Food imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
            if (res == cResourceFavor)
			if (ShowAiEcho == true) aiEcho("Favor imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);			
		}
	}
	
    if (fishingReset == true)
    {
        kbEscrowAllocateCurrentResources();
        return;
	}
    if (needReset == true)
    {
        failCount = failCount+1;
        if ((failCount > 5) || (failCount > 0) && (xsGetTime() < 1*30*1000))
        {
            if (ShowAiEcho == true) aiEcho("ERROR:  Escrow balances invalid.  Reallocating");
            kbEscrowAllocateCurrentResources();
		}
	}
    else
	failCount = 0;
	
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    static int count = 0;
	static int countB = 0;
	int ReserveAmount = 90;
	if (cMyCulture == cCultureAtlantean)
    ReserveAmount = 125;
	
    int mainBaseUnitID = getMainBaseUnitIDForPlayer(cMyID);	 
	
    if (kbGetAge() > cAge1)
    {
        if (foodSupply < ReserveAmount)
        {
            kbEscrowFlush(cMilitaryEscrowID, cResourceFood, true);
            if (ShowAiEcho == true) aiEcho("Flushing military food escrow");
            if ((kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0) && (foodSupply < ReserveAmount))
            {
                if ((aiGetMarketBuyCost(cResourceFood) < goldSupply) && (count > 1))
                {
                    aiBuyResourceOnMarket(cResourceFood);
                    if (ShowAiEcho == true) aiEcho("Food supply below 90, buying food.");
                    count = 0;
				}
                else
				count = count + 1;
			}			
		}
        else
        {
			count = 0;
		}
        if ((woodSupply <= 25) && (cMyCulture == cCultureAtlantean))
        {
			kbEscrowFlush(cMilitaryEscrowID, cResourceWood, true);		
            if ((kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0) && (woodSupply < 25))
            {
                if ((aiGetMarketBuyCost(cResourceWood) < goldSupply) && (countB > 1))
                {
                    aiBuyResourceOnMarket(cResourceWood);
                    if (ShowAiEcho == true) aiEcho("Wood supply below 25, buying Wood.");
                    countB = 0;
				}
                else
				countB = countB + 1;
			}
		}	
        else
        {		
			countB = 0;
		}		
		
	}
	  
    if (kbGetAge() == cAge2)
    {
        if ((foodSupply > 800) && (goldSupply > 500) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
        {
            aiTaskUnitResearch(mainBaseUnitID, gAge3MinorGod);
            if (ShowAiEcho == true) aiEcho("tasking research of tech ID"+gAge3MinorGod);
		}
        
        if ((aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true) > 0) && (kbUnitCount(0, cUnitTypeAbstractSettlement) > 0) && 
		(aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSettlementLevel1, true) > 0) && (xsGetTime() < 16*60*1000) &&
		(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < gEarlySettlementTarget) && (ShouldIAgeUp() == false))
        {
            if ((cMyCulture != cCultureEgyptian) && (woodSupply > 400) && (goldSupply > 400) && (foodSupply < 560) && (foodSupply > 150) || (cMyCulture == cCultureEgyptian) && (goldSupply > 400) && (foodSupply < 560) && (foodSupply > 150))
            {
                kbEscrowFlush(cMilitaryEscrowID, cResourceWood, true);
                kbEscrowFlush(cMilitaryEscrowID, cResourceGold, true);
                if (ShowAiEcho == true) aiEcho("Flushing wood and gold escrow");
			}
		}
		int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAlive);
        if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechWatchTower, true) >= 0) && (numTowers > 0))
        {
            if ((woodSupply > 250) && (goldSupply > 150))
            aiTaskUnitResearch(findUnit(cUnitTypeTower), cTechWatchTower);
		}		
	}
    else if (kbGetAge() == cAge3)
    {
        if ((kbGetTechStatus(cTechFortifyTownCenter) < cTechStatusResearching) && (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, cTechFortifyTownCenter, true) >= 0))
        {
            if ((woodSupply > 400) && (goldSupply > 400) && (kbUnitCount(0, cUnitTypeAbstractSettlement) > 0))
			{
				aiTaskUnitResearch(mainBaseUnitID, cTechFortifyTownCenter);
				if (ShowAiEcho == true) aiEcho("tasking research of tech ID"+cTechFortifyTownCenter);
			}
		}	
        if ((foodSupply > 1000) && (goldSupply > 1000) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) && (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0))
        {
            aiTaskUnitResearch(mainBaseUnitID, gAge4MinorGod);
            if (ShowAiEcho == true) aiEcho("tasking research of tech ID"+gAge4MinorGod);
		}
        if ((aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true) > 0) && (kbUnitCount(0, cUnitTypeAbstractSettlement) > 0) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < 3) 
		&& (xsGetTime() < 25*60*1000) && (ShouldIAgeUp() == false))
        {
            if ((cMyCulture != cCultureEgyptian) && (woodSupply > 400) && (goldSupply > 400) && (foodSupply > 200) || (cMyCulture == cCultureEgyptian) && (goldSupply > 450) && (foodSupply > 250))
            {
                kbEscrowFlush(cMilitaryEscrowID, cResourceWood, true);
                kbEscrowFlush(cMilitaryEscrowID, cResourceGold, true);
                if (ShowAiEcho == true) aiEcho("Flushing wood and gold escrow");
			}
		}		
	}
    else if (kbGetAge() > cAge3)
    {
        if ((cMyCulture == cCultureGreek) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching) && (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechForgeofOlympus, true) >= 0))
        {
            if ((goldSupply > 300) && (favorSupply > 30))
            {
                aiTaskUnitResearch(findUnit(cUnitTypeArmory), cTechForgeofOlympus);
                if (ShowAiEcho == true) aiEcho("Flushing economy favor and gold escrow");
			}
		}
        
        if ((kbGetTechStatus(cTechFortifyTownCenter) < cTechStatusResearching) && (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, cTechFortifyTownCenter, true) >= 0))
        {
            if ((woodSupply > 400) && (goldSupply > 400))
            {
                aiTaskUnitResearch(mainBaseUnitID, cTechFortifyTownCenter);
                if (ShowAiEcho == true) aiEcho("tasking research of tech ID"+cTechFortifyTownCenter);
			}
		}
        if ((aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true) > 0) && (kbUnitCount(0, cUnitTypeAbstractSettlement) > 0))
        {
            if ((cMyCulture != cCultureEgyptian) && (woodSupply > 400) && (goldSupply > 400) && (foodSupply > 200) || (cMyCulture == cCultureEgyptian) && (goldSupply > 450) && (foodSupply > 250))
            {
                kbEscrowFlush(cMilitaryEscrowID, cResourceWood, true);
                kbEscrowFlush(cMilitaryEscrowID, cResourceGold, true);
                if (ShowAiEcho == true) aiEcho("Flushing wood and gold escrow");
			}
		}
        if ((foodSupply >= 800) && (goldSupply >= 800) && (woodSupply >= 800) && (favorSupply >= 50) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && 
		(TitanAvailable == true) && (gTransportMap == false))
        {
            aiTaskUnitResearch(mainBaseUnitID, cTechSecretsoftheTitans);
            if (ShowAiEcho == true) aiEcho("tasking research of tech ID"+cTechSecretsoftheTitans);
		}		
	}
}

//==============================================================================
void updateEM(int econPop=-1, int milPop=-1, float econPercentage=0.5,
float rootEscrow=0.2, float econFoodEscrow=0.5, float econWoodEscrow=0.5,
float econGoldEscrow=0.5, float econFavorEscrow=0.5)
{
    if (cMyCulture == cCultureNorse) // Make room for at least 3 oxcarts
    {
        if (econPop < 25)
		econPop = econPop + 3;
	}
	
    //Econ Pop (if we're allowed to change it).
    if ((gHardEconomyPopCap > 0) && (econPop > gHardEconomyPopCap))
	econPop=gHardEconomyPopCap;
    if ( (econPop > cvMaxGathererPop)  && (cvMaxGathererPop >= 0) )
	econPop = cvMaxGathererPop;
	
    // Check if we're second age.  If so, consider capping the mil lower for boomers
    if (kbGetAge() == cAge2)
    {
        if ( (gRushGoalID == -1) ||   /* If we don't have a rush goal, or... */
		(aiPlanGetVariableInt(gRushGoalID, cGoalPlanExecuteCount, 0) >= aiPlanGetVariableInt(gRushGoalID, cGoalPlanRepeat, 0)) 
		)  // We have a rush goal, but we're done rushing
        {
            // Let's decrease our military pop
            float milPopDelta = (cvRushBoomSlider*4.0)/5.0;    // Zero for balanced, -.80 for extreme boom
            if (milPopDelta > 0) 
			milPopDelta = 0;  // Don't increase for rushers
            // Adjust it for econ/mil scale.  If military, soften the decrease, if economic, preserve full.
            milPopDelta = milPopDelta / (2.0 + cvMilitaryEconSlider);
            milPop = milPop + (milPop * milPopDelta);
		}
		if (milPop < 40) 
		milPop = 40;
		if (gAgeReduceMil == true)
		milPop = eMaxMilPop;		
	}
	
    if ((milPop < 0) && (cvMaxMilPop >= 0))      // milPop says no limit, but cvMaxMilPop has one
	milPop = cvMaxMilPop;      
    if ((milPop > cvMaxMilPop) && (cvMaxMilPop >= 0))  // cvMaxMilPop has limit and milPop is over it
	milPop = cvMaxMilPop;
	
    aiSetEconomyPop(econPop);
    aiSetMilitaryPop(milPop);
	
    // Check to make sure attack goals have ranges below our milPop limit
    int upID = gRushUPID;
    if (kbGetAge() > cAge2)
	upID = gLateUPID;
	
    int milMin = kbUnitPickGetMinimumPop(upID);
    int milMax = kbUnitPickGetMaximumPop(upID);
    if (milMax > milPop) // We have a problem
    {
        if (ShowAiEcho == true) aiEcho("***** MilPop is "+milPop+", resetting military goals.");
        kbUnitPickSetMaximumPop(upID,(milPop*4)/5);
        kbUnitPickSetMinimumPop(upID,(milPop*3)/5);
	}
    
    //Percentages.
    aiSetEconomyPercentage(1.0);
    aiSetMilitaryPercentage(1.0);
	
    //Get the amount of the non-root pie.
    float nonRootEscrow=1.0-rootEscrow;
    //Track whether or not we need to redistribute the resources.
    //Econ Food Escrow.
    float v=nonRootEscrow*econFoodEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceFood, v);
    //Econ Wood Escrow
    v=nonRootEscrow*econWoodEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceWood, v);
    //Econ Gold Escrow
    v=nonRootEscrow*econGoldEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceGold, v);
    //Econ Favor Escrow
    v=nonRootEscrow*econFavorEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceFavor, v);
    //Military Escrow.
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFood, nonRootEscrow*(1.0-econFoodEscrow));
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceWood, nonRootEscrow*(1.0-econWoodEscrow));
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceGold, nonRootEscrow*(1.0-econGoldEscrow));
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFavor, nonRootEscrow*(1.0-econFavorEscrow));
	
	
    int vilPop= aiGetEconomyPop();      // Total econ
    if (gFishing == true)
    {
        int fishCount = gNumBoatsToMaintain;
        if ( (aiGetGameMode() == cGameModeLightning) && (fishCount > 5) )
		fishCount = 5;
        vilPop = vilPop - fishCount; // Less fishing
	}
	
    int tradeCartPUID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0);
    int numTradeUnits = kbUnitCount(cMyID, tradeCartPUID, cUnitStateAlive);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive);
    if (numMarkets > 0)
    {
        int tradeCount = numTradeUnits;
        if ((aiGetGameMode() == cGameModeLightning) && (tradeCount > 5))
		tradeCount = 5; 
		vilPop = vilPop - tradeCount;     // Vils = total-trade
	}
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int numMainBaseGoldSites = kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy, 85.0);
    int numGoldBaseSites = 0;
    if ((gGoldBaseID >= 0) && (gGoldBaseID != mainBaseID))    // Count gold base if different
	numGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);
    int numGoldSites = numMainBaseGoldSites + numGoldBaseSites;
	
    if ((numGoldSites < 1) && (xsGetTime() > 20*60*1000) && (kbGetAge() > cAge2))
    {   
        vilPop = vilPop - 12;
	}
    
    if ((vilPop < 36) && (kbGetAge() > cAge1))
	vilPop = 36;
    
    if (cMyCulture == cCultureAtlantean)
	vilPop = vilPop / 3;
	
    // Brutal hack to make Lightning work.
    if (aiGetGameMode() == cGameModeLightning)
    {     // Make sure we don't try to overtrain villagers
        int lightningLimit = 25;      // Greek/Egyptian;
        if (cMyCulture == cCultureNorse)
		lightningLimit = 20;
        else if (cMyCulture == cCultureAtlantean)
		lightningLimit = 6;
        if (vilPop > lightningLimit)
		vilPop = lightningLimit;
	}
	
    //Update the number of vils to maintain.
	int gathererPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer,0);
	if ((kbCanAffordUnit(gathererPUID, cEconomyEscrowID) == true) && (kbUnitCount(cMyID, gathererPUID, cUnitStateAlive) < vilPop * 0.8) && 
	(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) > 0) && (kbGetPopCap() != kbGetPop()) && (AgingUp() == false))
	{
		static int FailedToTrain = 0;
		static int LastCount = 0;
		int CurrentTrained = aiPlanGetNumberVariableValues(gCivPopPlanID, cTrainPlanTrainedUnitID);
		if (CurrentTrained > LastCount)
		{
			FailedToTrain = 0;
			LastCount = CurrentTrained;
		}
		else if (CurrentTrained == LastCount)
		{
			FailedToTrain = FailedToTrain+1;
		}
		if (FailedToTrain >= 4)
		{
			aiPlanDestroy(gCivPopPlanID);
			FailedToTrain = 0;
			LastCount = 0;
			createCivPopPlan();
		}
	}
    aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0, vilPop);
}

//==============================================================================
rule updateEMAllAges
minInterval 14 //starts in cAge1
active
{
	int civPopTarget=-1;
	int milPopTarget=-1;
    static int ageStartTime3 = -1;
    static int ageStartTime4 = -1;		
    float econPercent = 1.0;     // Econ priority rating, range 0..1
    float econEscrow = 1.0;      // Economy's share of non-root escrow, range 0..1
	
	if ((kbGetAge() < cAge2) && (aiGetWorldDifficulty() >= cDifficultyModerate))
	{
		civPopTarget = 25;
		milPopTarget = 60;
	}
	else if ((kbGetAge() == cAge2) || (kbGetAge() == cAge3) || (aiGetWorldDifficulty() <= cDifficultyModerate))
	{
		if (aiGetWorldDifficulty() == cDifficultyEasy)
		{
			civPopTarget = 15 + aiRandInt(4);
			milPopTarget = 26 + aiRandInt(8);   
		}
		else if (aiGetWorldDifficulty() == cDifficultyModerate)
		{
		    civPopTarget = 34; 
	        if (aiGetGameMode() == cGameModeLightning)
		    civPopTarget = 15;
	        milPopTarget = 50;
		}
		else if (aiGetWorldDifficulty() == cDifficultyHard)
		{
			civPopTarget = 65 - (cvRushBoomSlider*5.99); 
			if (getSoftPopCap() > 115)
			civPopTarget = civPopTarget + 0.3 * (getSoftPopCap()-115); 
			if ((aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35))  
			civPopTarget = 35;                                               
			milPopTarget = getSoftPopCap() - civPopTarget;	
		}
		else
		{
			civPopTarget = 51 - (cvRushBoomSlider*5.99); 
			if ((aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35))
			civPopTarget = 35;  
			milPopTarget = getSoftPopCap() - civPopTarget;
		}
		if ((gAgeReduceMil == true) && (kbGetAge() == cAge2))
		milPopTarget = eMaxMilPop;	
	    else if ((gAgeReduceMil == true) && (kbGetAge() == cAge3))
		milPopTarget = eHMaxMilPop;
	
		if ((kbGetAge() == cAge3) && (ageStartTime3 == -1))
		ageStartTime3 = xsGetTime();
	}
	else if (kbGetAge() >= cAge4)
	{
		if (aiGetWorldDifficulty() == cDifficultyHard)
		{
	        if ((EcoUpgDone() == false) || (TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
			civPopTarget = 65 - (cvRushBoomSlider*5.99);
		    else
			civPopTarget = 56;
		}
		else
		civPopTarget = 51; 
		
		if (gGlutRatio > 1.0)
		civPopTarget = civPopTarget / gGlutRatio;
		if ( (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 10*60*1000) )
		civPopTarget = 35;   // limited for first 10 minutes while resource glut remains
		civPopTarget = civPopTarget + 0.2 * (getSoftPopCap()-115);  // Plus 20% over 115
		if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		civPopTarget = 35;
		milPopTarget = getSoftPopCap() - civPopTarget;
		
		if ((kbGetAge() == cAge4) && (ageStartTime4 == -1))
		ageStartTime4 = xsGetTime();		
	}
	
	if (kbGetAge() > cAge1)
	{
		if ((aiGetWorldDifficulty() >= cDifficultyHard) && (kbGetAge() >= cAge3))
		{
		    kbUnitPickSetMinimumPop(gLateUPID, milPopTarget*.5);
            kbUnitPickSetMaximumPop(gLateUPID, milPopTarget*.75);
		}
		
		if (kbGetAge() == cAge2)
		{
			econPercent = 0.5;
			econEscrow = 0.5; 
		}
		else if (kbGetAge() == cAge3)
		{
			econPercent = 0.3;
			econEscrow = 0.3; 
		}
		else
		{
			econPercent = 0.15;
			econEscrow = 0.15; 
		}		
		float econAdjust = -.5 * cvMilitaryEconSlider;  // For econ purist, do lesser of 50% econ boost or 50% mil cut
		// For hawk, vice versa 
		// Check and see if we're way below our target econ pop.  If so, boost the econ.
		float econShortage = aiGetAvailableEconomyPop();      // i.e., target minus actual
		float econTarget = aiGetEconomyPop();                 // i.e. our script-defined limit. 
		econShortage = econShortage / econTarget;    // i.e. 1.0 means we have no villagers, 0.0 means we're at target
		econAdjust = econAdjust + econShortage;    // if we're 30% low, boost it 30%
		if (econAdjust > 1.0)
		econAdjust = 1.0;
		if (econAdjust < -1.0)
		econAdjust = -1.0;
		
		econPercent = adjustSigmoid(econPercent, econAdjust, 0.0, 1.0);   // Adjust econ up or mil down by econAdjust amount, whichever is smaller
		econEscrow = econPercent;	
		
		if ((econEscrow > 0.60) && (kbGetAge()== cAge2))
		econEscrow = 0.60;
		else if ((econEscrow > 0.45) && (kbGetAge() > cAge2))
		econEscrow = 0.45;
		
		if ((xsGetTime() > 13*60*1000) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
		{
			if (econEscrow < 0.55)
			econEscrow = 0.55;
		}
		
		if ((xsGetTime() > 22*60*1000) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) && (xsGetTime() - ageStartTime3 > 6*60*1000)
		|| (kbGetAge() == cAge3) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) && (xsGetTime() - ageStartTime3 > 3*60*1000) && (ShouldIAgeUp() == true))
		{
			if (econEscrow < 0.45)
			econEscrow = 0.45;
		}
		
		if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (gTransportMap == false) && (xsGetTime() - ageStartTime4 > 3*60*1000))
		{
			if (econEscrow < 0.40)
			econEscrow = 0.40;
		}
		
		if (econEscrow < 0.10)
		econEscrow = 0.10;
	}
	//Update all the econ stuff
	updateEM(civPopTarget, milPopTarget, econPercent, 0.15, econEscrow, econEscrow, econEscrow, econEscrow); // add 15% into the savings account.
}

//==============================================================================
rule updatePrices   // This rule constantly compares actual supply vs. forecast, updates AICost // values (internal resource prices), and buys/sells at the market as appropriate
active
minInterval 6
{
    // check for valid forecasts, exit if not ready
    if (((gGoldForecast + gWoodForecast + gFoodForecast) < 100) || (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 11*60*1000))
	return; 
	static int lastRequestTime = 0;	
    float scaleFactor = 5.0;      // Higher values make prices more volatile
    float goldStatus = 0.0;
    float woodStatus = 0.0;
    float foodStatus = 0.0;
    float minForecast = 200.0 * (1 + kbGetAge());	// 200, 400, 600, 800 in ages 1-5, prevents small amount from looking large if forecast is very low
    if (gGoldForecast > minForecast)
	goldStatus = scaleFactor * kbResourceGet(cResourceGold)/gGoldForecast;
    else
	goldStatus = scaleFactor * kbResourceGet(cResourceGold)/minForecast;
    if (gFoodForecast > minForecast)
	foodStatus = scaleFactor * kbResourceGet(cResourceFood)/gFoodForecast;
    else
	foodStatus = scaleFactor * kbResourceGet(cResourceFood)/minForecast;
    if (gWoodForecast > minForecast)
	woodStatus = scaleFactor * kbResourceGet(cResourceWood)/gWoodForecast;
    else
	woodStatus = scaleFactor * kbResourceGet(cResourceWood)/minForecast;
	
    // Status now equals inventory/forecast
    // Calculate value rate of wood:gold and food:gold.  1.0 means they're of the same status, 2.0 means 
    // that the resource is one forecast more scarce, 0.5 means one forecast more plentiful, i.e. lower value.
    float woodRate = (1.0 + goldStatus)/(1.0 + woodStatus);
    float foodRate = (1.0 + goldStatus)/(1.0 + foodStatus);
	
    // The rates are now the instantaneous price for each resource.  Set the long-term prices by averaging this in
    // at a 5% weight.
	//aiEcho("ForecastGold:  "+gGoldForecast +"."+ " ForecastWood: "+gWoodForecast +"."+ " ForecastFood: "+gFoodForecast);
    float cost = 0.0;
	
    // wood
    cost = kbGetAICostWeight(cResourceWood);
    cost = (cost * 0.95) + (woodRate * .05);
    kbSetAICostWeight(cResourceWood, cost);
	
    // food
    cost = kbGetAICostWeight(cResourceFood);
    cost = (cost * 0.95) + (foodRate * .05);
    kbSetAICostWeight(cResourceFood, cost);
	
    // Gold
    kbSetAICostWeight(cResourceGold, 1.00);	// gold always 1.0, others relative to gold
    
    // Favor
    float favorCost = 15.0 - (14.0*(kbResourceGet(cResourceFavor)/100.0));     // 15 when empty, 1.0 when full
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((kbGetTechStatus(gAge4MinorGod) >= cTechStatusResearching) && (cMyCulture == cCultureGreek))
    {
        if ((kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching) && (favorSupply < 75) && (gAge4MinorGod == cTechAge4Hephaestus))
		favorCost = 40.0;
        else
        {
            if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (foodSupply > 500) && (goldSupply > 500) && (woodSupply > 500) && (favorSupply <= 70))
            {
                favorCost = 25.0;
			}
            else if (favorSupply > 70)
			favorCost = 15.0 - (14.0*(kbResourceGet(cResourceFavor)/100.0));
		}
	}
    
    if (favorCost < 1.0)
	favorCost = 1.0;
    kbSetAICostWeight(cResourceFavor, favorCost);  
	
    //Compare that to the market price.  Buy if
    // the market price is lower and we have at least 
    // 1/3 forecast of gold.  Sell if market price is higher and
    // we have at least 1/3 forecast of the resource.
    if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0)
    {
        float reserve = 500.0;
        if (kbGetAge() > cAge3)
		reserve = 800.0;
		
        if ( (goldStatus > 0.33) && (kbResourceGet(cResourceGold) > reserve) )	// We have some reserve of gold, OK to buy
        {
            if (((aiGetMarketBuyCost(cResourceFood)/100.0) < kbGetAICostWeight(cResourceFood)) && (kbResourceGet(cResourceFood) < 600))	// Market cheaper than our rate?
            {
                aiBuyResourceOnMarket(cResourceFood);
			}
            if (((aiGetMarketBuyCost(cResourceWood)/100.0) < kbGetAICostWeight(cResourceWood)) && (kbResourceGet(cResourceWood) < 600))	// Market cheaper than our rate?
            {
                aiBuyResourceOnMarket(cResourceWood);
			}
		}
        
        if ((woodStatus > 0.33) && (kbResourceGet(cResourceWood) > reserve))	// We have some reserve of wood, OK to sell
        {
            if (((aiGetMarketSellCost(cResourceWood)/100.0) > kbGetAICostWeight(cResourceWood)) && (kbResourceGet(cResourceGold) < 600))	// Market rate higher??
            {
                aiSellResourceOnMarket(cResourceWood);
			}
		}
        
        if ((foodStatus > 0.33) && (kbResourceGet(cResourceFood) > reserve))	// We have some reserve of food, OK to sell
        {
            if (((aiGetMarketSellCost(cResourceFood)/100.0) > kbGetAICostWeight(cResourceFood)) && (kbResourceGet(cResourceGold) < 600))	// Market rate higher??
            {
                aiSellResourceOnMarket(cResourceFood);
			}
		}
		if (kbResourceGet(cResourceGold) > 1300)	// We have a lot of gold, OK to buy
        {
            if (kbResourceGet(cResourceFood) < 1200)
            {
                if (kbResourceGet(cResourceGold) > 1800)
                {
                    for (i = 0; < 5)
                    {
                        aiBuyResourceOnMarket(cResourceFood);
					}
				}
                else
                {
                    aiBuyResourceOnMarket(cResourceFood);
				}
			}
            if (kbResourceGet(cResourceWood) < 800)
            {
                if (kbResourceGet(cResourceGold) > 1800)
                {
                    for (i = 0; < 5)
                    {
                        aiBuyResourceOnMarket(cResourceWood);
					}
				}
                else
                {
                    aiBuyResourceOnMarket(cResourceWood);
				}
			}
		}
		
        if (kbResourceGet(cResourceFood) > 1400)	// We have a lot of food, OK to sell
        {
            if (kbResourceGet(cResourceGold) < 1200)
            {
                if (kbResourceGet(cResourceFood) > 4000)
                {
                    for (i = 0; < 12)
                    {
                        aiSellResourceOnMarket(cResourceFood);
					}
				}
                else if (kbResourceGet(cResourceFood) > 1800)
                {
                    for (i = 0; < 5)
                    {
                        aiSellResourceOnMarket(cResourceFood);
					}
				}				
                else
                {
                    aiSellResourceOnMarket(cResourceFood);
				}
			}
		}		
	}
    // Update the gather plan goal
    for (i = 0; < 3)
    {
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, i, kbGetAICostWeight(i));
	}
	
    if ((AoModAllies == true) && (kbGetAge() > cAge1))
    { 
		if (((xsGetTime() - lastRequestTime) > 300000) && ((xsGetTime() - gLastSentTime) > 120000))
		{
			float totalResources = kbResourceGet(cResourceFood) + kbResourceGet(cResourceWood) + kbResourceGet(cResourceGold);
			if (totalResources > 1000.0)
			{
				if (kbResourceGet(cResourceFood) < (totalResources / 10.0))
				{
					MessageRel(cPlayerRelationAlly, RequestFood);
					lastRequestTime = xsGetTime();
					if (ShowAIComms == true) aiEcho("Requesting Food!");
				}
				if (kbResourceGet(cResourceGold) < (totalResources / 10.0))
				{
					MessageRel(cPlayerRelationAlly, RequestGold);
					lastRequestTime = xsGetTime();
					if (ShowAIComms == true) aiEcho("Requesting Gold!");
				}
				if (kbResourceGet(cResourceWood) < (totalResources / 10.0))
				{
					MessageRel(cPlayerRelationAlly, RequestWood);
					lastRequestTime = xsGetTime();
					if (ShowAIComms == true) aiEcho("Requesting Wood!");
				}
			}
		}
	} 	
	
	// Special Treatment for excess gold as requested, thanks StinnerV!
	bool Ok = true;
	if ((foodSupply > 10000) && (goldSupply > mGoldBeforeTrade) && (woodSupply > 10000))
	Ok = false;
	
	if ((aiGetWorldDifficulty() > cDifficultyEasy) && (kbGetAge() > cAge3 && xsGetTime() > 14*60*1000) && (Ok == true))
	{
		if (goldSupply > mGoldBeforeTrade)
		{
			if (woodSupply > foodSupply)
			aiBuyResourceOnMarket(cResourceFood);
			else
			aiBuyResourceOnMarket(cResourceWood);  
		}
	}
}

//==============================================================================
void updateGathererRatios(void) //Check the forecast variables, check inventory, set assignments
{
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
	
    float foodMultiplier = 1.2;      // Because food is so much slower to gather, inflate need
	
    gFoodForecast = gFoodForecast * foodMultiplier;
	
    float goldShortage = gGoldForecast - goldSupply;
    if (goldShortage < 0)
	goldShortage = 0;
    float woodShortage = gWoodForecast - woodSupply;
    if (woodShortage < 0)
	woodShortage = 0;
    float foodShortage = gFoodForecast - foodSupply;
    if (foodShortage < 0)
	foodShortage = 0;
	
    gGlutRatio = 100.0;     // ludicrously high
    if ( (goldSupply/gGoldForecast) < gGlutRatio )
	gGlutRatio = goldSupply/gGoldForecast;
    if ( (woodSupply/gWoodForecast) < gGlutRatio )
	gGlutRatio = woodSupply/gWoodForecast;
    if ( (foodSupply/gFoodForecast) < gGlutRatio )
	gGlutRatio = foodSupply/gFoodForecast;
    gGlutRatio = gGlutRatio * 1.85;   // Double it, i.e. start reducing civ pop when all resources are > 50% of forecast.
    if (gGlutRatio > 3.0)
	gGlutRatio = 3.0;    // Never cut econ below 1/3 of normal, but.. wait until we're in Mythic Age
	if ((kbGetAge() < cAge4) || (xsGetTime() < 25*60*1000)
	|| (TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
	gGlutRatio = 0.0;
	
    float totalShortage = goldShortage + woodShortage + foodShortage;
    if (totalShortage < 1)
	totalShortage = 1;
	
    float worstShortageRatio = goldShortage/(gGoldForecast+1);
    if ( (woodShortage/(gWoodForecast+1)) > worstShortageRatio)
	worstShortageRatio = woodShortage/(gWoodForecast+1);
    if ( (foodShortage/(gFoodForecast+1)) > worstShortageRatio)
	worstShortageRatio = foodShortage/(gFoodForecast+1);
	
	
    float totalForecast = gGoldForecast + gWoodForecast + gFoodForecast;
    if (totalForecast < 1)
	totalForecast = 1;	// Avoid div by 0.
	
    float numGatherers = kbUnitCount(cMyID,cUnitTypeAbstractVillager, cUnitStateAlive);
    if (cMyCulture == cCultureAtlantean)
	numGatherers = numGatherers * 3;    // Account for pop slots
	
    float numTradeCarts = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0), cUnitStateAlive);
	
    float numFishBoats = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive);
    if (numFishBoats >= 1)
	numFishBoats = numFishBoats - 1; // Ignore scout
	
    float civPopTotal = numGatherers + numTradeCarts + numFishBoats;
	
    int doomedID = -1;   // Who to kill...
    if (civPopTotal > (aiGetEconomyPop() + 5))
    {  
        // We need to delete something
        if (ShowAiEcho == true) aiEcho("We need to delete an econ unit");
        if (numGatherers > numTradeCarts) // Gatherer or fish boat
        {
            if (numGatherers > numFishBoats)
            {
                //find idle units first
                doomedID = findUnit(cUnitTypeAbstractVillager, cUnitStateAlive, cActionIdle, cMyID);
                if (doomedID < 0)
				doomedID = findUnit(cUnitTypeAbstractVillager);
                if (ShowAiEcho == true) aiEcho("Deleting a villager. "+doomedID);
			}
            else
            {
                //find idle units first
                doomedID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive, cActionIdle, cMyID);
                if (doomedID < 0)
				doomedID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0));
                if (ShowAiEcho == true) aiEcho("Deleting a fishing boat. "+doomedID);
			}
		}
        else  // Trade cart or fish boat
        {
            if (numTradeCarts > numFishBoats)
            {
                //find idle units first
                doomedID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0), cUnitStateAlive, cActionIdle, cMyID);
                if (doomedID < 0)
				doomedID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0));
                if (ShowAiEcho == true) aiEcho("Deleting a trade cart. "+doomedID);
			}
            else
            {
                //find idle units first
                doomedID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive, cActionIdle, cMyID);
                if (doomedID < 0)
				doomedID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0));
                if (ShowAiEcho == true) aiEcho("Deleting a fishing boat. "+doomedID);
			}
		}
        aiTaskUnitDelete(doomedID);
        if (cMyCulture == cCultureAtlantean)
		numGatherers = numGatherers - 3;
        else
		numGatherers = numGatherers - 1;
	}
	
    // Figure out what percent of our total civ pop we want working on each resource.  To do that,
    // figure out what the percentages would be to match our shortages, and the percents to match
    // our forecast, and come up with a weighted average of the two.  That way, if we don't have a wood shortage
    // at the moment, but we do expect to keep using wood, we'll keep some villagers on wood.
	
    // This much (forecastWeight) of the allocation is based on forecast, the rest on shortages.
    // If the biggest shortage is nearly equal to the forecast (nothing on hand), let
    // the shortage dominate.  If the shortage is relatively small, let the
    // forecast dominate
    float forecastWeight = 1.0 - worstShortageRatio;	
    float goldForecastRatio = gGoldForecast / totalForecast;
    float woodForecastRatio = gWoodForecast / totalForecast;
    float foodForecastRatio = gFoodForecast / totalForecast;
	
    float goldShortageRatio = 0.0;
    if (totalShortage > 0)
	goldShortageRatio = goldShortage / totalShortage;
    float woodShortageRatio = 0.0;
    if (totalShortage > 0)
	woodShortageRatio = woodShortage / totalShortage;
    float foodShortageRatio = 0.0;
    if (totalShortage > 0)
	foodShortageRatio = foodShortage / totalShortage;
	
    float desiredGoldRatio = forecastWeight*goldForecastRatio + (1.0-forecastWeight)*goldShortageRatio;
    float desiredWoodRatio = forecastWeight*woodForecastRatio + (1.0-forecastWeight)*woodShortageRatio;
    float desiredFoodRatio = forecastWeight*foodForecastRatio + (1.0-forecastWeight)*foodShortageRatio;
	
    // We now have the desired ratios, which can be converted to total civilian units, but then need to be adjusted for trade
    // carts and fishing boats.
    float desiredGoldUnits = desiredGoldRatio * civPopTotal;
    float desiredWoodUnits = desiredWoodRatio * civPopTotal;
    float desiredFoodUnits = desiredFoodRatio * civPopTotal;

    float neededGoldGatherers = desiredGoldUnits - numTradeCarts;
    int mainBaseID = kbBaseGetMainID(cMyID);
    int numMainBaseGoldSites = kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy, 85.0);
    int numGoldBaseSites = 0;
    if ((gGoldBaseID >= 0) && (gGoldBaseID != mainBaseID))    // Count gold base if different
	numGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy, 85);
    int numGoldSites = numMainBaseGoldSites + numGoldBaseSites;
	
	float neededWoodGatherers = desiredWoodUnits;
    if (woodSupply > 3000)
	neededWoodGatherers = neededWoodGatherers / 4;
	if (goldSupply > 3000)	
	neededGoldGatherers = neededGoldGatherers / 4;
	
	int numberMainBaseSites = kbGetNumberValidResources(mainBaseID, cResourceWood, cAIResourceSubTypeEasy, 85);
    int numberWoodBaseSites = kbGetNumberValidResources(gWoodBaseID, cResourceWood, cAIResourceSubTypeEasy, 85);
	int WoodCombined = numberMainBaseSites + numberWoodBaseSites;
	
	if (numGoldSites < 1)
	neededGoldGatherers = 0;
	if (WoodCombined < 1)
	neededWoodGatherers = 0;
    
    bool foodOverride = false;
	if (kbGetAge() > cAge3)
	foodOverride = true; 
    float neededFoodGatherers = desiredFoodUnits - numFishBoats;
    if ((desiredFoodUnits > 0) && (kbGetAge() > cAge1))
    {
        float minFoodGatherers = 10;
        if (cMyCulture == cCultureAtlantean)
		minFoodGatherers = 4;
        if ((numFishBoats < 4) && (kbGetAge() > cAge2) && (numberMainBaseSites < 1) || (numGoldSites < 1))
        {
            foodOverride = true;
            minFoodGatherers = 21;
            if (cMyCulture == cCultureAtlantean)
			minFoodGatherers = 8;
		}
        if (neededFoodGatherers < minFoodGatherers)
		neededFoodGatherers = minFoodGatherers;
	}
	
    if (neededGoldGatherers < 0)
	neededGoldGatherers = 0;
    if (neededFoodGatherers < 0)
	neededFoodGatherers = 0;
    if (neededWoodGatherers < 0)
	neededWoodGatherers = 0;
	
    float totalNeededGatherers = neededGoldGatherers + neededFoodGatherers + neededWoodGatherers;
    // Note, this total may be different than the total gatherers, if the trade carts are more than needed, or if
    // the fishing boats supply more food than we need, so this number may be lower...and should be used as the basis
    // for assigning villager percentages.
	
    float goldAssignment = neededGoldGatherers / totalNeededGatherers;
    float woodAssignment = neededWoodGatherers / totalNeededGatherers;
    float foodAssignment = neededFoodGatherers / totalNeededGatherers;
    
	float lastGoldAssignment = aiGetResourceGathererPercentage(cResourceGold, cRGPActual);
    float lastWoodAssignment = aiGetResourceGathererPercentage(cResourceWood, cRGPActual);
    float lastFoodAssignment = aiGetResourceGathererPercentage(cResourceFood, cRGPActual);
	
	if (kbGetAge() > cAge2)
	{	
		if (neededGoldGatherers > 0)
		{
			if (goldAssignment > lastGoldAssignment)
			{
				goldAssignment = lastGoldAssignment + 0.03;
				if (goldAssignment > 0.45)
                goldAssignment = 0.45;
			}
			else if (goldAssignment < lastGoldAssignment)
			{
				goldAssignment = lastGoldAssignment - 0.03;
				if (goldAssignment < 0.05)
                goldAssignment = 0.05;
			}
		}
		if (neededWoodGatherers > 0)
		{
			if (woodAssignment > lastWoodAssignment)
			{
				woodAssignment = lastWoodAssignment + 0.03;
				if (woodAssignment > 0.45)
                woodAssignment = 0.45;
			}
			else if (woodAssignment < lastWoodAssignment)
			{
				woodAssignment = lastWoodAssignment - 0.03;
				if (woodAssignment < 0.05)
                woodAssignment = 0.05;
			}
		}
		if (neededFoodGatherers > 0)
		{
			if (foodAssignment > lastFoodAssignment)
			{
				foodAssignment = lastFoodAssignment + 0.03;
				if ((foodAssignment > 0.70) && (kbGetAge() > cAge1))
				{
					if (foodOverride == false)
                    foodAssignment = 0.70;
				}
			}
			else if (foodAssignment < lastFoodAssignment)
			{
				foodAssignment = lastFoodAssignment - 0.03;
			}
		}
	}
	if (foodAssignment < 0.25)
	foodAssignment = 0.25;	
	
	//Test
    //if we lost a lot of villagers, keep them close to our settlements (=farming)
    int minVillagers = 14;
    if (cMyCulture == cCultureAtlantean)
	minVillagers = 5;
	if (aiGetWorldDifficulty() > cDifficultyHard)
	minVillagers = minVillagers / 2;		
    int numVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    if ((numVillagers <= minVillagers) && (kbGetAge() > cAge2) && (xsGetTime() > 16*60*1000))
    {
        goldAssignment = 0.1;
        woodAssignment = 0.2;
        foodAssignment = 0.7;
	}
	//Test end
    
    aiSetResourceGathererPercentageWeight( cRGPScript, 1.0);
    aiSetResourceGathererPercentageWeight( cRGPCost, 0.0);
    aiSetResourceGathererPercentage( cResourceGold, goldAssignment, false, cRGPScript);
    aiSetResourceGathererPercentage( cResourceWood, woodAssignment, false, cRGPScript);
    aiSetResourceGathererPercentage( cResourceFood, foodAssignment, false, cRGPScript);
    if (cMyCulture == cCultureGreek)
    {
        if (kbGetAge() < cAge3)
        {
            aiSetResourceGathererPercentage(cResourceFavor, 0.05, false, cRGPScript);
		}
        else if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
        {
            aiSetResourceGathererPercentage(cResourceFavor, 0.06, false, cRGPScript);
		}
        else
        {
            int favorPriority = 41;
            
            if ((gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching) && (favorSupply < 75))
            {
                aiSetResourceGathererPercentage(cResourceFavor, 0.18, false, cRGPScript);
                favorPriority = 50;
			}
            else
            {
                if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (foodSupply > 500) && (goldSupply > 500) && (woodSupply > 500) && (favorSupply <= 70))
                {
                    aiSetResourceGathererPercentage(cResourceFavor, 0.18, false, cRGPScript);
                    favorPriority = 50;
				}
                else
                {
                    aiSetResourceGathererPercentage(cResourceFavor, 0.06, false, cRGPScript);
				}
			}
            
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, kbBaseGetMainID(cMyID));
		}
	}
	
    aiNormalizeResourceGathererPercentages( cRGPScript );
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, aiGetResourceGathererPercentage(cResourceGold, cRGPScript));
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, aiGetResourceGathererPercentage(cResourceWood, cRGPScript));
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, aiGetResourceGathererPercentage(cResourceFood, cRGPScript));
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, aiGetResourceGathererPercentage(cResourceFavor, cRGPScript));
	if (gSomeData != -1)
    { 
        aiPlanSetUserVariableInt(gSomeData, cResourceFood, 0 , gFoodForecast);
        aiPlanSetUserVariableInt(gSomeData, cResourceGold, 0 , gGoldForecast);
		aiPlanSetUserVariableInt(gSomeData, cResourceWood, 0 , gWoodForecast);	
		aiPlanSetUserVariableFloat(gSomeData, 4, 0 , aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood) * 100);
	    aiPlanSetUserVariableFloat(gSomeData, 5, 0 , aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold) * 100);
	    aiPlanSetUserVariableFloat(gSomeData, 6, 0 , aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood) * 100);
	}
    if (ShowAiEcho == true) aiEcho("Our current forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");	
}

void addUnitForecast(int unitTypeID=-1, int qty=1)
{
	if (unitTypeID < 0)
	return;
	gGoldForecast = gGoldForecast + kbUnitCostPerResource(unitTypeID, cResourceGold)*qty;
	gWoodForecast = gWoodForecast + kbUnitCostPerResource(unitTypeID, cResourceWood)*qty;
	gFoodForecast = gFoodForecast + kbUnitCostPerResource(unitTypeID, cResourceFood)*qty;
}


void addTechForecast(int techID=-1)
{
	if (techID < 0)
	return;
	gGoldForecast = gGoldForecast + kbTechCostPerResource(techID, cResourceGold);
	gWoodForecast = gWoodForecast + kbTechCostPerResource(techID, cResourceWood);
	gFoodForecast = gFoodForecast + kbTechCostPerResource(techID, cResourceFood);
}
//==============================================================================
// setMilitaryUnitCostForecast
// Checks the current age, looks into the appropriate unit picker,
// calculates approximate resource needs for the next few (3?) minutes,
// adds this amount to the global vars.
//==============================================================================
void setMilitaryUnitCostForecast(void)
{
	int upID = -1;  // ID of the unit picker to query
	float totalAmount = 0.0;	// Total resources to be spent in near future
	if (kbGetAge() == cAge2)
	{
		upID = gRushUPID;
		totalAmount = 1200;
	}
	if (kbGetAge() == cAge3)
	{
		upID = gLateUPID;
		totalAmount = 3000;
	}
	if (kbGetAge() >= cAge4)
	{
		upID = gLateUPID;
		totalAmount = 5000;
	}
	
	int origGold = gGoldForecast;
	int origWood = gWoodForecast;
	int origFood = gFoodForecast;
	
	
	float goldCost = 0.0;
	float woodCost = 0.0;
	float foodCost = 0.0;
	float totalCost = 0.0;
	
	int unitID = kbUnitPickGetResult( upID, 0); // Primary unit
	float weight = 1.0;
	int numUnits = kbUnitPickGetDesiredNumberUnitTypes(upID);
	
	if (numUnits == 2)
	weight = 0.67; // 2/3 and 1/3
	if (numUnits >= 3)
	weight = 0.50; // 1/2, 1/3, 1/6
	if (ShowAiEcho == true) aiEcho("Military Unit Cost Forecast:");
	if (ShowAiEcho == true) aiEcho(" Main unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
	
	goldCost = kbUnitCostPerResource(unitID, cResourceGold);
	woodCost = kbUnitCostPerResource(unitID, cResourceWood);
	foodCost = kbUnitCostPerResource(unitID, cResourceFood);
	totalCost = goldCost+woodCost+foodCost;
	
	gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
	
	if (numUnits > 1)
	{  // Do second unit
		unitID = kbUnitPickGetResult(upID, 1);
		weight = 0.25;	// Second is 1/3 regardless 
		if (ShowAiEcho == true) aiEcho("   Secondary unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
		goldCost = kbUnitCostPerResource(unitID, cResourceGold);
		woodCost = kbUnitCostPerResource(unitID, cResourceWood);
		foodCost = kbUnitCostPerResource(unitID, cResourceFood);
		totalCost = goldCost+woodCost+foodCost;
		
		gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
		gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
		gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
	}
	
	if (numUnits > 2)
	{  // Do third unit
		unitID = kbUnitPickGetResult(upID, 2);
		weight = 0.25;   // Third unit, if used, is 1/6
		if (ShowAiEcho == true) aiEcho("   Tertiary unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
		goldCost = kbUnitCostPerResource(unitID, cResourceGold);
		woodCost = kbUnitCostPerResource(unitID, cResourceWood);
		foodCost = kbUnitCostPerResource(unitID, cResourceFood);
		totalCost = goldCost+woodCost+foodCost;
		
		gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
		gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
		gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
	}
	if (ShowAiEcho == true) aiEcho(" Mil forecast gold: "+(gGoldForecast-origGold)+", wood: "+(gWoodForecast-origWood)+", food: "+(gFoodForecast-origFood));
}

void AddGenForecastNeeds(void)
{
	
    // Villagers & Farms   
	int temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  
	if (temp > 12)
	temp = 12;
	if (cMyCulture == cCultureAtlantean)
	if (temp > 4)
	temp = 4;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	
    if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
		temp = 0;
		if (temp > 8)
		temp = 8; 
	    if ((temp > 2) && (kbGetAge() < cAge2))
		temp = 2;
		
		if (temp > 0)
		addUnitForecast(cUnitTypeFarm, temp);		
	}  
    if ((gFishing == true) && (kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding) >= 1))
    {
        int Number = 50;
		if (kbGetAge() < cAge2)
	    Number = 125;
		int fishBoatType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
		int boatCount = kbUnitCount(cMyID, fishBoatType, cUnitStateAlive);
	    temp = gNumBoatsToMaintain - boatCount;
		if (temp <= 1)
		temp = 1;
		gWoodForecast = gWoodForecast + Number*temp;
	}
	
    if ((kbGetAge() >= cAge2) || (kbGetTechStatus(gAge2MinorGod) == cTechStatusResearching))
	{	
		int Armory = cUnitTypeArmory;
        if (cMyCiv == cCivThor)
        Armory = cUnitTypeDwarfFoundry;
		// Settlements
		if ((kbUnitCount(0, cUnitTypeAbstractSettlement) > 0) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < 3))
		addUnitForecast(cUnitTypeSettlementLevel1, 1);
	    if ((cMyCulture != cCultureNorse) && (kbGetTechStatus(cTechGuardTower) < cTechStatusResearching))
	    addTechForecast(cTechGuardTower);
        if ((kbUnitCount(cMyID, Armory, cUnitStateAliveOrBuilding) < 1) && (cMyCulture != cCultureEgyptian))
        addUnitForecast(Armory, 1);
	
	    if ((kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 2) && (cMyCiv == cCivNuwa) && (kbGetAge() == cAge2))
        addUnitForecast(cUnitTypeMarket, 1);	
	
        // military buildings
        if (kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsThatTrainMilitary, cUnitStateAliveOrBuilding) < 4)
	    {
		    if (cMyCulture == cCultureEgyptian)
		    gGoldForecast = gGoldForecast + 300;
		    else
	        gWoodForecast = gWoodForecast + 300;
	    }	
		
		if (gNavalAttackGoalID != -1)
		{
			gWoodForecast = gWoodForecast + 350;
			// Ships
			int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
			temp = gTargetNavySize+2 - myShips;   // How many yet to train
			if (temp < 0)
			temp = 0;
			if (temp > 0)
			{
				gWoodForecast = gWoodForecast + 175*temp;
				gGoldForecast = gGoldForecast + 100*temp;
			}		
		}        
		if (kbGetAge() >= cAge3)
		{
	        if (gTransportMap == true)
	        gWoodForecast = gWoodForecast + 350;
	        // Market
            if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 2)
            addUnitForecast(cUnitTypeMarket, 1);		
			// Fortress, etc.
			if (kbUnitCount(cMyID, MyFortress, cUnitStateAliveOrBuilding) < 10)
            addUnitForecast(MyFortress, 1);
			
		    // Fortified TC
		    if (kbGetTechStatus(cTechFortifyTownCenter) < cTechStatusResearching) 
		    addTechForecast(cTechFortifyTownCenter);			
		}
	}		
}

//==============================================================================
rule econForecastAge4		// Rule activates when age 4 research begins
minInterval 12
inactive
{	
    static int ageStartTime = -1;
	int temp = 0;
    
    if ( (kbGetAge() == cAge3) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) )	// Upgrade failed, revert
    {
        if (ShowAiEcho == true) aiEcho("Age 4 upgrade failed.");
        xsDisableSelf();
        xsEnableRule("econForecastAge3");
        return;
	}
    else if ((kbGetAge() > cAge3) && (ageStartTime == -1))
	ageStartTime = xsGetTime();
	
    gGoldForecast = 1000;
    gWoodForecast = 1000;
    gFoodForecast = 1000;
	
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
	
    if ((ageStartTime != -1) && (xsGetTime() - ageStartTime > 5*60*1000))
    {
        if (foodSupply < 1200)
		gFoodForecast = gFoodForecast + (1200 - foodSupply);
        if (woodSupply < 1000)
		gWoodForecast = gWoodForecast + (1000 - woodSupply);
        if (goldSupply < 1100)
		gGoldForecast = gGoldForecast + (1100 - goldSupply);
	}
    else
    {
        if (goldSupply < 500)
		gGoldForecast = gGoldForecast + (500 - goldSupply);
        if (woodSupply < 500)
		gWoodForecast = gWoodForecast + (500 - woodSupply);
        if (foodSupply < 500)
		gFoodForecast = gFoodForecast + (500 - foodSupply);
	}
    
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (xsGetTime() - ageStartTime > 4*60*1000))
	addTechForecast(cTechSecretsoftheTitans);
	
	AddGenForecastNeeds();
	setMilitaryUnitCostForecast(); // add units before scaling down
    
	if (woodSupply > 1700)
	gWoodForecast = gWoodForecast * 0.5;
    else if (woodSupply > 1600)
	gWoodForecast = gWoodForecast * 0.6;
    else if (woodSupply > 1500)
	gWoodForecast = gWoodForecast * 0.7;
    else if (woodSupply > 1400)
	gWoodForecast = gWoodForecast * 0.8;
    else if (woodSupply > 1300)
	gWoodForecast = gWoodForecast * 0.9;
    updateGathererRatios();
}

//==============================================================================
rule econForecastAge3		// Rule activates when age3 research begins, turns off when age 4 research begins
minInterval 11
inactive
{
    static int ageStartTime = -1;
    int temp = 0;
    if (kbGetTechStatus(gAge4MinorGod) >=  cTechStatusResearching)	// On our way to age 4, hand off...
    {
        xsEnableRule("econForecastAge4");
        econForecastAge4();
        xsDisableSelf();
        return;		// We're done
	}
    else if ((kbGetAge() == cAge2) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))	// Upgrade failed, revert
    {
        if (ShowAiEcho == true) aiEcho("Age 3 upgrade failed.");
        xsDisableSelf();
        xsEnableRule("econForecastAge2");
        return;
	}
    else if ((kbGetAge() == cAge3) && (ageStartTime == -1))
	ageStartTime = xsGetTime();
	
    if (ShowAiEcho == true) aiEcho("age 3 start time: "+ageStartTime);
    
	gFoodForecast = 700;
    gGoldForecast = 500;
    gWoodForecast = 500;

    if ((ageStartTime != -1) && (xsGetTime() - ageStartTime > 6*60*1000))
    {
       gFoodForecast = gFoodForecast + 1300;
       gGoldForecast = gGoldForecast + 900;
    }	
	
    AddGenForecastNeeds();
	setMilitaryUnitCostForecast(); // add units before scaling down
    updateGathererRatios();
}

//==============================================================================
rule econForecastAge2		// Rule activates when age 2 research begins, turns off when age 3 research begins
minInterval 10
inactive
{
    static int ageStartTime = -1;
	
    int temp = 0;
    if (kbGetTechStatus(gAge3MinorGod) >= cTechStatusResearching) 	// On our way to age 3, hand off...
    {
        xsEnableRule("econForecastAge3");
        econForecastAge3();
        xsDisableSelf();
        return;		// We're done
	}
    else if ((kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching))	// Upgrade failed, revert
    {
        if (ShowAiEcho == true) aiEcho("Age 2 upgrade failed.");
        xsDisableSelf();
        xsEnableRule("econForecastAge1");
        return;
	}
    else if ((kbGetAge() == cAge2) && (ageStartTime == -1))
	ageStartTime = xsGetTime();
	
    if (ShowAiEcho == true) aiEcho("age 2 start time: "+ageStartTime);
    
    // If we've made it here, we're in age 2 (or researching it)
	gFoodForecast = 600;
	gGoldForecast = 400;
    gWoodForecast = 400;
   
    if ((ageStartTime != -1) && (xsGetTime() - ageStartTime > 6*60*1000))
    {
       gFoodForecast = gFoodForecast + 1000;
       gGoldForecast = gGoldForecast + 600;
    }	
	
    // plow etc
    if ((kbGetTechStatus(cTechPlow) < cTechStatusResearching) && (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding) > 0))
    addTechForecast(cTechPlow);
	if (kbGetTechStatus(cTechShaftMine) < cTechStatusResearching)
	addTechForecast(cTechShaftMine);
	if (kbGetTechStatus(cTechBowSaw) < cTechStatusResearching)
	addTechForecast(cTechBowSaw);
    
	AddGenForecastNeeds();
	if (xsGetTime() - ageStartTime > 2*60*1000)
	setMilitaryUnitCostForecast(); // add units before scaling down
    else
    {
       if (gFarming == false)   
       gWoodForecast = gWoodForecast + 700;
    }			 
    updateGathererRatios();
}

//==============================================================================
rule econForecastAge1		// Rule active for mid age 1 (cAge1), gets started in setEarlyEcon rule, ending when next age upgrade starts
minInterval 4
inactive
{
    if (kbGetAge() > cAge1)
    {
        xsDisableSelf();
        xsEnableRule("econForecastAge2");
        return;
	}
	int mainBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAlive);
	if ((kbGetAge() == cAge1) && (kbResourceGet(cResourceFood) >= 400) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching))
    aiTaskUnitResearch(mainBaseUnitID, gAge2MinorGod);
	
    if (kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)	
    {	// Next age upgrade is on the way
        xsDisableSelf();
        xsEnableRule("econForecastAge2");
        econForecastAge2();	// Since runImmediately doesn't seem to be working
	    if (cMyCulture == cCultureEgyptian)
        gHouseAvailablePopRebuild=30;
        else
        gHouseAvailablePopRebuild=18;		
        return;
	}
	
    // If we've made it here, we're in age 1 (cAge1), we've been in the age at least 2 minutes,
    // and we haven't started the age 2 upgrade.  Let's see what we need.
    
	gFoodForecast = 600.0;
	gGoldForecast = 100.0;
    gWoodForecast = 100.0;
	
	if (xsGetTime() > 2*60*1000)
    {
	    if ((kbUnitCount(cMyID, cUnitTypeGuild, cUnitStateAliveOrBuilding) < 1) && (cMyCulture == cCultureAtlantean))
        addUnitForecast(cUnitTypeGuild, 1);	
        if ((kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding) < 1) || (cMyCulture == cCultureEgyptian)) // add an extra one too if it is still not up.
    	addUnitForecast(cUnitTypeTemple, 1);
		
		if (cMyCulture == cCultureAtlantean)
		addUnitForecast(cUnitTypeManor, 1);
	    else
		addUnitForecast(cUnitTypeHouse, 2);
	}
    
	AddGenForecastNeeds();
	if (gFoodForecast < 700)
	gFoodForecast = 700;
    updateGathererRatios();
}

//==============================================================================
void initGreek(void)
{
    //Modify our favor need.  A pseudo-hack.
    aiSetFavorNeedModifier(10.0);
	
    //Greek scout types.
    gLandScout=cUnitTypeScout;
    gAirScout=cUnitTypePegasus;
    gWaterScout=cUnitTypeFishingShipGreek;
	
    //Greeks gather with heroes.
    gGatherRelicType=cUnitTypeHero;
	
    //Create the Greek scout plan.
	
    int exploreID=aiPlanCreate("Explore_SpecialGreek", cPlanExplore);
    if (exploreID >= 0)
    {
        aiPlanAddUnitType(exploreID, cUnitTypeScout, 1, 1, 1);
        aiPlanSetDesiredPriority(exploreID, 30);
        aiPlanSetActive(exploreID);
	}
	
    //Poseidon.
    if (cMyCiv == cCivPoseidon)
	gWaterScout=cUnitTypeHippocampus;
	
	
	// Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	
    // Control variable overrides
    if (cvAge2GodChoice != -1)
	gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
	gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
	gAge4MinorGod = cvAge4GodChoice;
}

//==============================================================================
void initEgyptian(void)
{
	
	//Create a simple TC empower plan
	
	gEmpowerPlanID=aiPlanCreate("Pharaoh Empower", cPlanEmpower);
	if (gEmpowerPlanID >= 0)
	{
		aiPlanSetEconomy(gEmpowerPlanID, true);
		if (cvMapSubType == VINLANDSAGAMAP)
		aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 0, 0, 1);
		else
		aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 1, 1, 1);
		aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeGranary);
		aiPlanSetDesiredPriority(gEmpowerPlanID, 85);
		aiPlanSetActive(gEmpowerPlanID);
	}
	
	
    //Egyptian scout types.
    gLandScout=cUnitTypePriest;
    gAirScout=-1;
    gWaterScout=cUnitTypeFishingShipEgyptian;
    //Egyptians gather with their Pharaoh
    gGatherRelicType=cUnitTypePharaoh;
    
    //Create a simple plan to maintain Priests for land exploration.
    createSimpleMaintainPlan(cUnitTypePriest, gMaintainNumberLandScouts, true, kbBaseGetMainID(cMyID));
	
    //Turn off auto favor gather.
    aiSetAutoFavorGather(false);
	
    //Set the build limit for Outposts.
    aiSetMaxLOSProtoUnitLimit(4);
	
	
    //Set.
	if (cMyCiv == cCivSet)
    {
        //Create air explore plans for the hyena.
        int explorePID=aiPlanCreate("Explore_SpecialSetHyena", cPlanExplore);
        if (explorePID >= 0)
        {
            aiPlanAddUnitType(explorePID, cUnitTypeHyenaofSet, 1, 1, 1);
            aiPlanSetActive(explorePID);
		}
	}
	
	// Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	
    // Control variable overrides
    if (cvAge2GodChoice != -1)
	gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
	gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
	gAge4MinorGod = cvAge4GodChoice;
}

//==============================================================================
void initNorse(void)
{
	
    //Set our trained dropsite PUID.
    aiSetTrainedDropsiteUnitTypeID(cUnitTypeOxCart);
	
	//Create a reserve plan for our main base for some Ulfsarks if we're not on VS, TM, or Nomad.
    if ((cvRandomMapName != "nomad") && (cvRandomMapName != "vinlandsaga") && (cvRandomMapName != "team migration"))
    {
        int ulfsarkReservePlanID=aiPlanCreate("UlfsarkBuilderReserve", cPlanReserve);
        if (ulfsarkReservePlanID >= 0)
        {
            aiPlanSetDesiredPriority(ulfsarkReservePlanID, 49);
            aiPlanSetBaseID(ulfsarkReservePlanID, kbBaseGetMainID(cMyID));
            aiPlanAddUnitType(ulfsarkReservePlanID, cUnitTypeAbstractInfantry, 1, 1, 1); 
            aiPlanSetVariableInt(ulfsarkReservePlanID, cReservePlanPlanType, 0, cPlanBuild);
            aiPlanSetActive(ulfsarkReservePlanID);
		}
	}
	//Create a simple plan to maintain X Ulfsarks.
	xsEnableRule("ulfsarkMaintain");
    // On easy or moderate, get two extra oxcarts ASAP before we're at econ pop cap
    if ( aiGetWorldDifficulty() <= cDifficultyModerate )
    {
        int easyOxPlan=aiPlanCreate("Easy/Moderate Oxcarts", cPlanTrain);
        if (easyOxPlan >= 0)
        {
            aiPlanSetVariableInt(easyOxPlan, cTrainPlanUnitType, 0, cUnitTypeOxCart);
            aiPlanSetVariableInt(easyOxPlan, cTrainPlanNumberToTrain, 0, 2); 
            aiPlanSetVariableInt(easyOxPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement); 
            aiPlanSetDesiredPriority(easyOxPlan, 100); 
            aiPlanSetActive(easyOxPlan);
		}
	}
	
    //Turn off auto favor gather.
    aiSetAutoFavorGather(false);
	
    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        int dmUlfPlan=aiPlanCreate("dm ulfsarks", cPlanTrain);
        if (dmUlfPlan >= 0)
        {
            aiPlanSetVariableInt(dmUlfPlan, cTrainPlanUnitType, 0, cUnitTypeUlfsark);
            //Train off of economy escrow.
            aiPlanSetEscrowID(dmUlfPlan, cEconomyEscrowID);
            aiPlanSetVariableInt(dmUlfPlan, cTrainPlanNumberToTrain, 0, 5); 
            aiPlanSetVariableInt(dmUlfPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement); 
            aiPlanSetDesiredPriority(dmUlfPlan, 99); 
            aiPlanSetActive(dmUlfPlan);
		}
	}
    //Norse scout types.
    gLandScout=cUnitTypeAbstractScout;
    gAirScout=-1;
    gWaterScout=cUnitTypeFishingShipNorse;
    //Norse gather with their heros.
    gGatherRelicType=cUnitTypeHeroNorse;
    if (cMyCiv == cCivOdin)
    gAirScout = cUnitTypeRaven;
    
	
	// Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	
    // Control variable overrides
    if (cvAge2GodChoice != -1)
	gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
	gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
	gAge4MinorGod = cvAge4GodChoice;
	
    //Enable our no-infantry check.
    xsEnableRule("norseInfantryCheck");
}

//==============================================================================
void initAtlantean(void)
{
    // Atlantean
    gLandScout=cUnitTypeOracleScout;
    gWaterScout=cUnitTypeFishingShipAtlantean;
    gAirScout=-1;
    gGatherRelicType = cUnitTypeHero;   //use any hero       
	
    //Create the atlantean scout plans.
    int exploreID=-1;
    int i = 0;
    
    for (i = 0; < 2)
    {
        exploreID = aiPlanCreate("Explore_SpecialAtlantean"+i, cPlanExplore);
        if (exploreID >= 0)
        {
            aiPlanAddUnitType(exploreID, cUnitTypeAbstractScout, 0, 1, 1);
            //aiPlanAddUnitType(exploreID, cUnitTypeOracleHero, 0, 1, 1);    // Makes sure the relic plan sees this plan as a hero source. Also crashes the game!
            aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(exploreID, cExplorePlanOracleExplore, 0, true);
            aiPlanSetDesiredPriority(exploreID, 80);  // Allow oracleHero relic plan to steal one
            aiPlanSetActive(exploreID);
		}
		
        if (i == 1)
		gLandExplorePlanID=exploreID;
	}  
	
	// Make sure we always have at least 1 oracles
	int oracleMaintainPlanID = createSimpleMaintainPlan(cUnitTypeOracleScout, 1, false, kbBaseGetMainID(cMyID));
	
    // Special emergency manor build for Lightning
    if (aiGetGameMode() == cGameModeLightning)
    {                                   
        // Build a manor, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
        createSimpleBuildPlan(cUnitTypeManor, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	}
	
    // Special emergency manor build for DeathMatch
    if (aiGetGameMode() == cGameModeDeathmatch)
    {                                   
        // Build a manor, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
        createSimpleBuildPlan(cUnitTypeManor, 5, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	}   
	
    aiSetAutoFavorGather(false);
	
    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	
    // Control variable overrides
    if (cvAge2GodChoice != -1)
	gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
	gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
	gAge4MinorGod = cvAge4GodChoice;
	
    // If I'm Kronos.. turn on unbuild..
    if (cMyCiv == cCivKronos)
	unbuildHandler();
	
    if (cMyCiv == cCivOuranos)
	xsEnableRule("buildSkyPassages");
}


//==============================================================================
void initChinese(void)
{
    // Chinese
	
    gLandScout=cUnitTypeScoutChinese;
    gWaterScout=cUnitTypeFishingShipChinese;
    gAirScout=-1;
    // Use any hero for gathering relics
    gGatherRelicType = cUnitTypeHeroChineseImmortal;   //use Immortal hero       
    gGardenBuildLimit = 10;
	
	if (cMyCiv == cCivFuxi)
	xsEnableRule("rSpeedUpBuilding");
	
	xsEnableRule("DelayImmortalHero"); 	
	createSimpleMaintainPlan(cUnitTypeHeroChineseGeneral, 2, false, kbBaseGetMainID(cMyID));
	cMonkMaintain = createSimpleMaintainPlan(cUnitTypeHeroChineseMonk, aiRandInt(2)+3, false, kbBaseGetMainID(cMyID));
	eChineseHero = createSimpleMaintainPlan(cUnitTypeHeroChineseImmortal, 0, true, kbBaseGetMainID(cMyID));  // Eco
    mChineseImmortal = createSimpleMaintainPlan(cUnitTypeHeroChineseImmortal, 0, false, kbBaseGetMainID(cMyID)); // Mil	
	
	//Create the Chinese scout plans.
    int exploreID=-1;
    int i = 0;
	
    for (i = 0; < 2)
    {
        exploreID = aiPlanCreate("Explore_Special_Chinese"+i, cPlanExplore);
        if (exploreID >= 0)
        {
            aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 0, 1, 1);
            aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 0, 1, 1); 
            aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetActive(exploreID);
		}  
	}
	
	// Make sure we always have at least 1 Scout Cavalry
	int ChineseScoutMaintainPlanID = createSimpleMaintainPlan(cUnitTypeScoutChinese, 1, false, kbBaseGetMainID(cMyID));
	
    // Special emergency house build for Lightning
    if (aiGetGameMode() == cGameModeLightning)
    {                                   
        // Build a house, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
        createSimpleBuildPlan(cUnitTypeHouse, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	}
	
    aiSetAutoFavorGather(false);
	
    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	
    // Control variable overrides
    if (cvAge2GodChoice != -1)
	gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
	gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
	gAge4MinorGod = cvAge4GodChoice;
}

rule DelayImmortalHero
minInterval 2
inactive
{
    if (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding) < 1)
	return;
    if (eChineseHero != -1)
    aiPlanSetVariableInt(eChineseHero, cTrainPlanNumberToMaintain, 0, 1);
	xsDisableSelf();
}
//==============================================================================
int initUnitPicker(string name="BUG", int numberTypes=1, int minUnits=10,
int maxUnits=20, int minPop=-1, int maxPop=-1, int numberBuildings=1,
bool guessEnemyUnitType=false)
{
    //Create it.
    int upID=kbUnitPickCreate(name);
    if (upID < 0)
	return(-1);
	
    //Default init.
	kbUnitPickResetAll(upID);
    //1 Part Preference, 2 Parts CE, 2 Parts Cost.
    kbUnitPickSetPreferenceWeight(upID, 2.0);
    kbUnitPickSetCombatEfficiencyWeight(upID, 4.0);
    kbUnitPickSetCostWeight(upID, 7.0);
    //Desired number units types, buildings.
    kbUnitPickSetDesiredNumberUnitTypes(upID, numberTypes, numberBuildings, true);
    //Min/Max units and Min/Max pop.
    kbUnitPickSetMinimumNumberUnits(upID, minUnits);
    kbUnitPickSetMaximumNumberUnits(upID, maxUnits);
    kbUnitPickSetMinimumPop(upID, minPop);
    kbUnitPickSetMaximumPop(upID, maxPop);
    //Default to land units.
    kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeLandMilitary);
    kbUnitPickSetGoalCombatEfficiencyType(upID, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);
	
    //Setup the military unit preferences.  These are just various strategies of unit
    //Bla bla, let's just randomize it, instead of locking it in place...
	
	if (cvPrimaryMilitaryUnit == -1)    // Skip this whole thing otherwise
	{
		switch (cMyCulture)
		{	
			case cCultureGreek:
			{
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4+aiRandInt(7));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7+aiRandInt(4));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3+aiRandInt(8));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.3);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.2);
				break;
			}
			case cCultureEgyptian:
			{
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2+aiRandInt(9));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7+aiRandInt(4));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3+aiRandInt(8));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.3);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeSiegeTower, 0.2);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeKhopesh, 0.0);
				if (cMyCiv == cCivSet)
				{	
					kbUnitPickSetPreferenceFactor(upID, cUnitTypeRhinocerosofSet, 0.1);
					kbUnitPickSetPreferenceFactor(upID, cUnitTypeCrocodileofSet, 0.1);
				}
				break;
			}
			case cCultureNorse:
			{
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3+aiRandInt(7));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1+aiRandInt(2));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3+aiRandInt(7));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.3);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
				break;
			}
			case cCultureAtlantean:
			{
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3+aiRandInt(6));    // vs inf
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5+aiRandInt(6));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2+aiRandInt(6));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.3);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
				break;
			}			
			case cCultureChinese:
			{
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4+aiRandInt(7));    // vs inf
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7+aiRandInt(4));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4+aiRandInt(7));
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.3);
				kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
				break;			
			}
		}		
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeDryad, 0.0);      // This should *only* be produced through the hesperides rule
	}  // End if / cvPrimaryMilitaryUnit
	
	
    if (cvNumberMilitaryUnitTypes >= 0)
    {  
        kbUnitPickSetDesiredNumberUnitTypes(upID, cvNumberMilitaryUnitTypes, numberBuildings, true);
        setMilitaryUnitPrefs(cvPrimaryMilitaryUnit, cvSecondaryMilitaryUnit, cvTertiaryMilitaryUnit);
	}
    //Done.
    return(upID);
}

//==============================================================================
void init(void)
{
    xsEnableRule("updateWoodBreakdown");
    xsEnableRule("updateFoodBreakdown");
    xsEnableRule("updateGoldBreakdown");
    //We're in a random map.
    aiSetRandomMap(true);
	
    //Adjust control variable sliders by random amount
    cvRushBoomSlider = (cvRushBoomSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
    if (cvRushBoomSlider > 1.0)
	cvRushBoomSlider = 1.0;
    if (cvRushBoomSlider < -1.0)
	cvRushBoomSlider = -1.0;
    cvMilitaryEconSlider = (cvMilitaryEconSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
    if (cvMilitaryEconSlider > 1.0)
	cvMilitaryEconSlider = 1.0;
    if (cvMilitaryEconSlider < -1.0)
	cvMilitaryEconSlider = -1.0;
    cvOffenseDefenseSlider = (cvOffenseDefenseSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
    if (cvOffenseDefenseSlider > 1.0)
	cvOffenseDefenseSlider = 1.0;
    if (cvOffenseDefenseSlider < -1.0)
	cvOffenseDefenseSlider = -1.0;
    if (ShowAiEcho == true) aiEcho("Sliders are...RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);
    
	
	
    //Startup messages.
    if (ShowAiEcho == true) aiEcho("Greetings, my name is "+cMyName+".");
    if (ShowAiEcho == true) aiEcho("AI Filename='"+cFilename+"'.");
    if (ShowAiEcho == true) aiEcho("MapName="+cvRandomMapName+".");
    if (ShowAiEcho == true) aiEcho("Civ="+kbGetCivName(cMyCiv)+".");
    if (ShowAiEcho == true) aiEcho("DifficultyLevel="+aiGetWorldDifficultyName(aiGetWorldDifficulty())+".");
    if (ShowAiEcho == true) aiEcho("Personality="+aiGetPersonality()+".");
	
    //Find someone to hate.
    if (cvPlayerToAttack < 1)
	updatePlayerToAttack();
    else
	aiSetMostHatedPlayerID(cvPlayerToAttack);
	
	
    //Bind our age handlers.
    aiSetAgeEventHandler(cAge2, "age2Handler");
    aiSetAgeEventHandler(cAge3, "age3Handler");
    aiSetAgeEventHandler(cAge4, "age4Handler");
    aiSetAgeEventHandler(cAge5, "age5Handler");
	
    if (cvMaxAge <= kbGetAge())      // Are we starting at or beyond our max age?
    {
        aiSetPauseAllAgeUpgrades(true);
	}
	
    //Setup god power handler
    aiSetGodPowerEventHandler("gpHandler");
	
    //Setup the resign handler
    aiSetResignEventHandler("resignHandler");
	
    //Set our town location.
    setTownLocation();
	
    //Economy.
    initEcon();
	
    //Progress.
    initProgress();
    
    //God Powers
    initGodPowers();

    //Create bases for all of our settlements.  Ignore any that already have
    //bases set.  If we have an invalid main base, the first base we create
    //will be our main base.
    static int settlementQueryID=-1;
    if (settlementQueryID < 0)
	settlementQueryID=kbUnitQueryCreate("MySettlements");
    if (settlementQueryID > -1)
    {
        kbUnitQuerySetPlayerID(settlementQueryID, cMyID);
        kbUnitQuerySetUnitType(settlementQueryID, cUnitTypeAbstractSettlement);
        kbUnitQuerySetState(settlementQueryID, cUnitStateAlive);
        kbUnitQueryResetResults(settlementQueryID);
        int numberSettlements=kbUnitQueryExecute(settlementQueryID);
        for (i=0; < numberSettlements)
        {
            int settlementID=kbUnitQueryGetResult(settlementQueryID, i);
            //Skip this settlement if it already has a base.
            if (kbUnitGetBaseID(settlementID) >= 0)
            {
                if (ShowAiEcho == true) aiEcho("settlement: "+settlementID+" already has a base, skipping it");
                continue;
			}
            vector settlementPosition=kbUnitGetPosition(settlementID);
            //Create a new base.
            int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), settlementPosition, 85.0);
            if (newBaseID > -1)
            {
                //Figure out the front vector.
                vector baseFront=xsVectorNormalize(kbGetMapCenter()-settlementPosition);
                kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
                //Military gather point.
                vector militaryGatherPoint=settlementPosition+baseFront*18.0;
                if (ShowAiEcho == true) aiEcho("main base settlementPosition is: "+settlementPosition);
                if (ShowAiEcho == true) aiEcho("main base militaryGatherPoint is: "+militaryGatherPoint);
                kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
                //Set the other flags.
                kbBaseSetMilitary(cMyID, newBaseID, true);
                kbBaseSetEconomy(cMyID, newBaseID, true);
                //Set the resource distance limit.
                kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
                //Add the settlement to the base.
                kbBaseAddUnit(cMyID, newBaseID, settlementID);
                kbBaseSetSettlement(cMyID, newBaseID, true);
                //Set the main-ness of the base.
                kbBaseSetMain(cMyID, newBaseID, true);
			}
		}
	}
	
	
    //Culture setup.
    switch (cMyCulture)
    {
        case cCultureGreek:
        {
            initGreek();
            break;
		}
        case cCultureEgyptian:
        {
            initEgyptian();
            break;
		}
        case cCultureNorse:
        {
            initNorse();
            break;
		}
        case cCultureAtlantean:
        {
            initAtlantean();
            break;
		}
        case cCultureChinese:
        {
            initChinese();
            break;
		}		
	}
    //My stuff
	initRethlAge1();
	//Map Specific
    initMapSpecific();
	
    //Setup the progression to follow these minor gods.
    kbTechTreeAddMinorGodPref(gAge2MinorGod);
    kbTechTreeAddMinorGodPref(gAge3MinorGod);
    kbTechTreeAddMinorGodPref(gAge4MinorGod);
    if (ShowAiEcho == true) aiEcho("Minor god plan is "+kbGetTechName(gAge2MinorGod)+", "+kbGetTechName(gAge3MinorGod)+", "+kbGetTechName(gAge4MinorGod));
	
    //Set the Explore Danger Threshold.
    aiSetExploreDangerThreshold(300.0);
    //Auto gather our military units.
    aiSetAutoGatherMilitaryUnits(false);
	
    //Get our house build limit.
    if (cMyCulture == cCultureAtlantean)
	gHouseBuildLimit = kbGetBuildLimit(cMyID, cUnitTypeManor);
    else
	gHouseBuildLimit=kbGetBuildLimit(cMyID, cUnitTypeHouse);
	
    //Set the housing rebuild bound to 4 for the first age.
    if (cMyCulture == cCultureEgyptian)
	gHouseAvailablePopRebuild=4;
    else if (cMyCulture == cCultureAtlantean)
	gHouseAvailablePopRebuild=5;
    else if (cMyCulture == cCultureNorse)
	gHouseAvailablePopRebuild=8;		
    else
	gHouseAvailablePopRebuild=5;
	
    //Set the hard pop caps.
    if (aiGetGameMode() == cGameModeLightning)
    {
        gHardEconomyPopCap=35;
        //If we're Norse, get our 5 dwarves.
        if (cMyCulture == cCultureNorse)
		createSimpleMaintainPlan(cUnitTypeDwarf, 5, true, -1);
	}
    else if (aiGetGameMode() == cGameModeDeathmatch)
	gHardEconomyPopCap=25;   // Essentially shut off vill production until age 4.
    else
    {
        if (aiGetWorldDifficulty() == cDifficultyEasy)
		gHardEconomyPopCap=20;
        else if (aiGetWorldDifficulty() == cDifficultyModerate)
		gHardEconomyPopCap=40;
        else
		gHardEconomyPopCap=-1;
	}
	
    //Set the default attack response distance.
	aiSetAttackResponseDistance(60.0);
	
    // always wall up, unless the map strictly said no.
	
	if (bWallUp == true)
	{
	    gBuildWalls = true;
        gBuildWallsAtMainBase = true;
	}
	
    if (mapPreventsWalls() == true)
    {
        gBuildWallsAtMainBase = false;
	}
	
	if (aiGetGameMode() == cGameModeDeathmatch)
	{
	    if (gWallsInDM == true)
		{
			gBuildWalls = true;
			gBuildWallsAtMainBase = true;
		}
	}	
    
    if (cvOkToBuildWalls == false)
    {
        gBuildWalls = false;
        gBuildWallsAtMainBase = false;
	}

    //set our default stance to defensive.
    aiSetDefaultStance(cUnitStanceDefensive);

    //Decide whether or not we're doing a rush/raid.
    // Rushers will use a smaller econ to age up faster, send more waves and larger waves.
    // Boomers will use a larger econ, hit age 2 later, make smaller armies, and send zero or few waves, hitting age 3 much sooner.
	
    int rushCount = 0;
    if (cvRushBoomSlider > -0.5) 
	rushCount = 1;    // Rushcount acts as a bool for the moment.  Rush unless strong boomer.
	
    int rushSize=70;      // Total pop to use in rush armies.
    rushSize = rushSize + (cvRushBoomSlider*(rushSize*0.6)); // Increase/decrease the size up to 60% for rushing 
    if (cvOffenseDefenseSlider > 0)
	rushSize = rushSize + (cvOffenseDefenseSlider*(rushSize*0.6)); // Increase the size up to 60% for offense 
	
    if (aiGetWorldDifficulty() == cDifficultyModerate)    // Take it easy on moderate
	rushSize = rushSize/2;
	
    if (aiGetWorldDifficulty() == cDifficultyEasy)  // Never rush on easy
    {
        rushCount = 0;
        rushSize = 10;
	}
	
    if (aiGetGameMode() == cGameModeDeathmatch)     // Never rush in DM
	rushCount = 0;
	
    if ((cvRandomMapName == "king of the hill") && (rushCount < 2))
	rushCount = 1;                               // Always rush in KotH, even on easy.
    
	
    //Specific maps prevent rushing.
    if (mapPreventsRush() == true)
	rushCount = 0;  
	
    if (rushCount >= 0)
    {  
        // Knock up to 40 pop slots off plan
		if (rushSize > 80)
		rushSize = rushSize - 40;
		else
		rushSize = rushSize/2;
	}
	
    int numTypes = 3;
	
    // Finally, adjust rushSize to the per-wave number we need
    if (rushCount > 0)
    {
        rushCount = (rushSize+20)/40;   // +20 to round to closest value
        rushSize = rushSize / rushCount;
	}
	
    if (rushSize > 65)
	rushSize = 65;
	
    if (rushSize < 32)
	rushSize = 32;  // Give unitpicker something to do...
	
    gRushUPID=initUnitPicker("Rush", numTypes, -1, -1, rushSize, rushSize*1.25, 2, false); // Rush with rushSize pop slots of 3 types and 2 buildings.
    if (ShowAiEcho == true) aiEcho("Setting rush unit picker for "+rushCount+" rushes with "+rushSize+" pop slots used.");
	
    // Set a smaller number for first wave.
    int newRushSize = 0;
    newRushSize = rushSize;
    if (rushCount >= 3)
	newRushSize = rushSize/3;
    else if (rushCount == 2)
	newRushSize = rushSize/2;
    if (newRushSize != rushSize)
    {
        kbUnitPickSetMinimumPop(gRushUPID, newRushSize);
        if (ShowAiEcho == true) aiEcho("Initial attack wave will use "+newRushSize+" pop slots.");
	}
    
    //new stuff for new land attack rule
    gRushSize = rushSize / 3;
    
    //set the gRushCount in order to enable the tech rules if we only have an idle attack goal in cAge2
    if (gRushCount > 0)
    {
        gRushCount = rushCount + 2;    //since our attack plans don't make several attempts, we increase the rush count
	}  
    else
    {
        gRushCount = rushCount;
	}
    
    //set the gFirstRushSize
    if (rushCount == 1) //gRushCount is now 2, so we need a smaller size for the first rush
    {
        gFirstRushSize = rushSize / 5;
	}
    else
    {
        gFirstRushSize = newRushSize / 3;
	}
	
    if (ShowAiEcho == true) aiEcho("gRushCount: "+gRushCount+", gRushSize: "+gRushSize+", gFirstRushSize: "+gFirstRushSize);
	
	if (gRushCount > 2)
	{
		gRushCount = gRushCount +1+aiRandInt(3);
		mRusher = true;
		BeenmRusher = true;
		//aiEcho("Rush count: "+gRushCount+"");
	}
	
	if ((aiGetWorldDifficulty() > cDifficultyModerate) && (gRushCount < 1))
	gRushCount = 2;	
	
    //Create our UP.
    if (gRushUPID >= 0)
    {
        //Reset a few of the UP parms.
        kbUnitPickSetPreferenceWeight(gRushUPID, 2.0);
        kbUnitPickSetCombatEfficiencyWeight(gRushUPID, 4.0);
        kbUnitPickSetCostWeight(gRushUPID, 7.0);
		
		if (cMyCulture == cCultureGreek)
        {
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeToxotes, 1.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeHoplite, 0.5);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeHippikon, 0.4);	 
		}
        if (cMyCulture == cCultureEgyptian)
        {
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeSlinger, 1.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeSpearman, 0.6);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeAxeman, 0.5);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypePriest, 0.0); // no, the maintain plan should be plenty.
		}
        if (cMyCulture == cCultureNorse)
        {
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeAbstractArcher, 0.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeRaidingCavalry, 0.6);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeAbstractInfantry, 0.5);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeHero, 0.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeThrowingAxeman, 0.8);
		}
        if (cMyCulture == cCultureAtlantean)
        {
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeJavelinCavalry, 1.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeSwordsman, 1.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeMaceman, 0.2);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeChieroballista, 0.1);
		}
        if (cMyCulture == cCultureChinese)
        {
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeChuKoNu, 1.0);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeScoutChinese, 0.8);
			kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeHalberdier, 0.5);
		}		
		
        //Create the rush goal if we're rushing.
        if (rushCount > 0)  // Deleted conditions that suppress rushing if we're walling or towering...OK to do some of each.
        {
            //Create the attack.
            gRushGoalID = createSimpleAttackGoal("Rush Land Attack", -1, gRushUPID, rushCount+1, 1, 1, kbBaseGetMainID(cMyID), false);
            if (gRushGoalID > 0)
            {
                //Go for hitpoint upgrade first.
                aiPlanSetVariableInt(gRushGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);      
                aGoalID = gRushGoalID;				
			}
		}
        else
        {
            //Create an idle attack goal that will maintain our military until the next age.
            gIdleAttackGID = createSimpleAttackGoal("Idle Force", -1, gRushUPID, -1, 1, 1, kbBaseGetMainID(cMyID), false);
            if (gIdleAttackGID >= 0)
            {
				aiPlanSetVariableBool(gIdleAttackGID, cGoalPlanIdleAttack, 0, true);
				aiPlanSetVariableInt(gIdleAttackGID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
				//Reset the rushUPID down to 3 unit type and 1 building.
				kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, numTypes, 1, true);
				aGoalID = gIdleAttackGID;	
			}
		}
	}
    
    
    //Create our late age attack goal.
    if (aiGetWorldDifficulty() == cDifficultyEasy)
	gLateUPID=initUnitPicker("Late", 1, -1, -1, 8, 16, gNumberBuildings - 1, false);
    else if (aiGetWorldDifficulty() == cDifficultyModerate)
    {
        int minPop=20+aiRandInt(14);
        int maxPop=minPop+16;
        if ( aiGetGameMode() != cGameModeDeathmatch )
		gLateUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, gNumberBuildings, false);   // Attack with at least 20-33 pop slots, no more than 36-49.
        else  // DM, double number of buildings
		gLateUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, 2*gNumberBuildings, false);   // Attack with at least 20-33 pop slots, no more than 36-49.
	}
    else
    {
        minPop=40+aiRandInt(20);
        maxPop=70;
        if (aiGetWorldDifficulty() > cDifficultyHard)
		maxPop = 90;
        
        if (ShowAiEcho == true) aiEcho("gLateUP minPop: "+minPop+", maxPop: "+maxPop);
        
        if (aiGetGameMode() != cGameModeDeathmatch)
		gLateUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, gNumberBuildings, false);    // Min: 40-59, max 70 pop slots
        else  // Double buildings in DM
		gLateUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, 2*gNumberBuildings, false);    // Min: 40-59, max 70 pop slots
	}
    
    int lateAttackAge = 2;
	
    if (gLateUPID >= 0)
    {
        if (aiGetGameMode() == cGameModeDeathmatch)
		lateAttackAge = 3;
		
        gLandAttackGoalID = createSimpleAttackGoal("Main Land Attack", -1, gLateUPID, -1, lateAttackAge, -1, kbBaseGetMainID(cMyID), true);
        if (gLandAttackGoalID >= 0)
        {
            //If this is easy, this is an idle attack.
            if (aiGetWorldDifficulty() == cDifficultyEasy)
			aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, true);
			
            aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
		}
	}
	
    //
    if ((aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch))
    {
        //-- reserve some building space in the base for the wonder.
        int wonderBPID = kbBuildingPlacementCreate("WonderBP");
        if (wonderBPID != -1)
        {
            kbBuildingPlacementSetBuildingType(cUnitTypeWonder );
            kbBuildingPlacementSetBaseID(kbBaseGetMainID(cMyID), cBuildingPlacementPreferenceBack);
            kbBuildingPlacementStart();
		}
		int BuilderType = cUnitTypeAbstractVillager;
		if (cMyCulture == cCultureNorse)
		BuilderType = cUnitTypeAbstractInfantry;	
        createBuildBuildingGoal("Wonder Goal", cUnitTypeWonder, 1, 3, 4, kbBaseGetMainID(cMyID), 30, BuilderType, true, 100, wonderBPID);
	}
	
    //Create our econ goal (which is really just to store stuff together).
    gGatherGoalPlanID=aiPlanCreate("GatherGoals", cPlanGatherGoal);
    if (gGatherGoalPlanID >= 0)
    {
        //Overall percentages.
	    aiPlanSetDesiredPriority(gGatherGoalPlanID, 90);	
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 0.0);
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanGathererPct, 4, true);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, 0.0);
		
		// Add early food base, borrowed from WarriorM
		findFoodBase();
        //Standard RB setup.
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, 5, true);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, 0);
	    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 1);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 0);
        //Hunt on Erebus and River Styx.
        if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
        {
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
			aiSetMinNumberNeedForGatheringAggressvies(1);
		}		 		
		
        //Min resource amounts.
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, 4, true);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceGold, 500.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceWood, 500.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceFood, 500.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceFavor, 50.0);
        //Resource skew.
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, 4, true);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceGold, 1000.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceWood, 1000.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceFood, 1000.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceFavor, 100.0);
        //Cost weights.
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, 4, true);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold, 1.5);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood, 1.5);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor, 10.0);
        //Set our farm limits.
		aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0, 20);  //  Up from 4
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanMaxFarmLimit, 0, 40);     //  Up from 24
        aiSetFarmLimit(aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0));
        //Do our late econ init.
        postInitEcon();
        //Lastly, update our EM.
        updateEMAllAges();
	}
	
    if ((aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning))  // Add an emergency temple, and 10 houses)
    {
        if (cMyCulture == cCultureAtlantean)
        {
            createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
            if (aiGetGameMode() == cGameModeDeathmatch)
			createSimpleBuildPlan(cUnitTypeManor, 2, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		}
        else
        {
            createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 5);
            if (aiGetGameMode() == cGameModeDeathmatch)
			createSimpleBuildPlan(cUnitTypeHouse, 4, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		}
	}
    xsEnableRule("buildInitialTemple");
    xsEnableRule("buildResearchGranary");
	
    // get all idle workers to random resources
    xsEnableRule("collectIdleVills");
    
    // research husbandry
    xsEnableRule("getHusbandry");
    
    // research hunting dogs
    xsEnableRule("getHuntingDogs");
    
    // age1 econ upgrades
    xsEnableRuleGroup("age1EconUpgrades");
    
    //enable the airScout rules if necessary
    if ((cMyCulture == cCultureGreek) || (cMyCiv == cCivOdin))
    {
        if (cMyCulture == cCultureGreek)
        {
            xsEnableRule("maintainAirScouts");
		}
        xsEnableRule("airScout1");
        xsEnableRule("airScout2");
	}
    
    //enable the fixJammedDropsiteBuildPlans rule
    if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureChinese))
	xsEnableRule("fixJammedDropsiteBuildPlans");
	
    //enable the tacticalBuildings rule
    xsEnableRule("tacticalBuildings");
    
    if (cMyCulture == cCultureAtlantean)
    {
        //enable our makeAtlanteanHeroes rule
        xsEnableRule("makeAtlanteanHeroes");
	}
    else
    {
        //enable our maintainHeroes rule
        xsEnableRule("maintainHeroes");
	}
    
    if (cMyCulture == cCultureEgyptian)
	{
		xsEnableRule("getHandsOfThePharaoh");
	    xsEnableRule("trainMercs");
	}

	
    if (cMyCulture != cCultureGreek)
    {
        //enable the relicUnitHandler rule
        xsEnableRule("relicUnitHandler");
	}
    
    //enable the startLandScouting rule
    xsEnableRule("startLandScouting");
	
    //enable the age1Progress rule
    xsEnableRule("age1Progress");
    
    //enable the buildHouse rule
    xsEnableRule("buildHouse");
    
    //enable the dockMonitor rule
    xsEnableRule("dockMonitor");
	
    //enable the spotAgeUpgrades rule
    xsEnableRule("spotAgeUpgrades");
    
    //Relics:  Always on Hard or Nightmare, 50% of the time on Moderate, Never on Easy.
    bool gatherRelics = true;
    if ((aiGetWorldDifficulty() == cDifficultyEasy) || ((aiGetWorldDifficulty() == cDifficultyModerate) && (aiRandInt(2) == 0)))
	gatherRelics = false;
    //If we're going to gather relics, do it.
    if (cvOkToGatherRelics == false)
	gatherRelics = false;
    if (gatherRelics == true)
    {
        xsEnableRule("goAndGatherRelics");
        if (ShowAiEcho == true) aiEcho("goAndGatherRelics enabled");
	}
    
    //Enable building repair.
    if (aiGetWorldDifficulty() != cDifficultyEasy)
    {
        xsEnableRule("repairBuildings1");
        xsEnableRule("repairBuildings2");
	}
    
    xsEnableRule("defendPlanRule");
    xsEnableRule("mainBaseDefPlan1");
    
    xsEnableRule("findMySettlementsBeingBuilt");
    
    //update player to attack
    xsEnableRule("updatePlayerToAttack");
	
	
    //Force an armory to go down
    xsEnableRule("buildArmory");
    
    setOverrides();      // Allow the loader to override anything it needs to.
}

//==============================================================================
void age2Handler(int age=1)
{
    gLastAgeHandled = cAge2;
    if (cvMaxAge == age)
    {
        aiSetPauseAllAgeUpgrades(true);
	} 
    
    xsEnableRule("monitorAttPlans");
    xsEnableRule("monitorDefPlans");
    xsEnableRule("baseAttackTracker");
    xsEnableRule("otherBasesDefPlans");
    xsEnableRule("getNextGathererUpgrade"); 
    
    //activate ObeliskClearingPlan if there is an Egyptian enemy,
    //enable the hesperides rule if there's an Oranos or Gaia player
    bool hesperidesPower = false;
	bool UWGate = false;
    int playerID = -1;
    for (playerID = 1; < cNumberPlayers)
    {
        if ((kbGetCivForPlayer(playerID) == cCivOuranos) || (kbGetCivForPlayer(playerID) == cCivGaia))
        {
            hesperidesPower = true;
            continue;
		}
        if ((playerID == cMyID) || (kbIsPlayerAlly(playerID) == true))
		continue;
        if ((kbGetCivForPlayer(playerID) == cCivZeus) || (kbGetCivForPlayer(playerID) == cCivHades))
        {
            UWGate = true;
            continue;
		}			
        
	}
    
    if (hesperidesPower == true)
	xsEnableRule("hesperides");
    if (UWGate == true)
	xsEnableRule("IHateUnderworldPassages");		
    
    //Econ.
    econAge2Handler(age);
    //Progress.
    progressAge2Handler(age);
    //GP.
    gpAge2Handler(age);
    //Naval
    navalAge2Handler(age);
	
    //Set the housing rebuild bound.
	if (cMyCulture == cCultureEgyptian)
    gHouseAvailablePopRebuild=30;
    else
    gHouseAvailablePopRebuild=18;
	
	
    //Switch the EM rule.
    updateEMAllAges();	// Make it run right now
	
    //If we're building towers, do that.  
	
	if (cMyCulture != cCultureEgyptian)
	xsEnableRule("getWatchTower");
	
	if ((cMyCulture == cCultureNorse) && (gAge2MinorGod == cTechAge2Heimdall))
	xsEnableRule("getSafeguard");
	
	xsEnableRule("getCrenellations");
	xsEnableRule("getSignalFires");
	xsEnableRule("buildMBTower");
	
    //Maintain a water transport, if this is a transport map.
    if ((gTransportMap == true) && (gMaintainWaterXPortPlanID < 0) || (cvRandomMapName == "king of the hill"))
    {
        gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 2, false, -1);
	}
	
    //Init our myth unit rule.
    xsEnableRule("trainMythUnit");
	
    //enable our raiding party rule
    xsEnableRule("createRaidingParty");
    
    //enable the randomAttackGenerator rule
    xsEnableRule("randomAttackGenerator");
    
    //enable the attackEnemySettlement rule
    xsEnableRule("attackEnemySettlement");
    
    //enable the createLandAttack rule
    xsEnableRule("createLandAttack");
	
    //variables for our buildplans
    vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector origLocation = location;
    vector frontVector = kbBaseGetFrontVector(cMyID, kbBaseGetMainID(cMyID));
    
    float fx = xsVectorGetX(frontVector);
    float fz = xsVectorGetZ(frontVector);
    float fxOrig = fx;
    float fzOrig = fz;
    vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    float bxOrig = bx;
    float bzOrig = bz;
	
    //Greek.
    if (cMyCulture == cCultureGreek)
    {
        //Create our hero maintain plans.  These do first and second age heroes.
        if (cMyCiv == cCivZeus)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekJason, 1, false, kbBaseGetMainID(cMyID));
            gHero2MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekOdysseus, 1, false, kbBaseGetMainID(cMyID));
		}
        else if (cMyCiv == cCivPoseidon)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekTheseus, 1, false, kbBaseGetMainID(cMyID));
            gHero2MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekHippolyta, 1, false, kbBaseGetMainID(cMyID));
		}
        else if (cMyCiv == cCivHades)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekAjax, 1, false, kbBaseGetMainID(cMyID));
            gHero2MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekChiron, 1, false, kbBaseGetMainID(cMyID));
		}
        aiPlanSetDesiredPriority(gHero1MaintainPlan, 100);
        aiPlanSetDesiredPriority(gHero2MaintainPlan, 100);
        
        xsEnableRuleGroup("techsGreekMinorGodAge2");
		
        if (cMyCiv == cCivHades)
        {
            //Enable the Vaults of Erebus rule
            xsEnableRule("getVaultsOfErebus");
		}
        else if (cMyCiv == cCivPoseidon)
        {
            //Enable the Lord of horses rule
            xsEnableRule("getLordOfHorses");
		}
        else if (cMyCiv == cCivZeus)
        {
            //Enable the Olympic parentage rule
            xsEnableRule("getOlympicParentage");
		}
	}
    //Egyptian.
    else if (cMyCulture == cCultureEgyptian)
    {
        //Always want 4 priests
        if (cMyCiv != cCivRa)
		gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypePriest, 4, false, kbBaseGetMainID(cMyID));
		
        //Move our pharaoh empower to a "Dropsite"
        if (gEmpowerPlanID != -1)
		aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeDropsite);
		
        //If we're Ra, create some more priests and empower with them.
        if (cMyCiv == cCivRa)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypePriest, 5, true, kbBaseGetMainID(cMyID));
			
			APlanID=aiPlanCreate("Mining Camp Empower", cPlanEmpower);
            if (APlanID >= 0)
            {
                aiPlanSetEconomy(APlanID, true);
                aiPlanAddUnitType(APlanID, cUnitTypePriest, 0, 1, 1);
                aiPlanSetVariableInt(APlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMiningCamp);
				aiPlanSetDesiredPriority(APlanID, 70);			
				aiPlanSetActive(APlanID);
			}
            BPlanID=aiPlanCreate("Lumber Camp Empower", cPlanEmpower);
            if (BPlanID >= 0)
            {
                aiPlanSetEconomy(BPlanID, true);
                aiPlanAddUnitType(BPlanID, cUnitTypePriest, 0, 1, 1);
                aiPlanSetVariableInt(BPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeLumberCamp);
                aiPlanSetDesiredPriority(BPlanID, 70);				
				aiPlanSetActive(BPlanID);
			}
		}        
        aiPlanSetDesiredPriority(gHero1MaintainPlan, 100);
		
        //Up the build limit for Outposts.
        aiSetMaxLOSProtoUnitLimit(8);
	}
    //Norse.
    else if (cMyCulture == cCultureNorse)
    {
        //We always want 3 Norse heroes.
        gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroNorse, 3, false, kbBaseGetMainID(cMyID));
        aiPlanSetDesiredPriority(gHero1MaintainPlan, 100);
		
        //Odin has ravens -> destroy unnecessary scout plans
        if (cMyCiv == cCivOdin)
        {
            aiPlanDestroy(gLandExplorePlanID);
			xsDisableRule("startLandScouting");
		}
	}
	
    if (cMyCiv == cCivOuranos)
    {
		//Enable the getSafePassage rule
		xsEnableRule("getSafePassage");
	}
    
	//Mil buildings
	int BuilderType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
	int BuildingType1 = cUnitTypeAcademy;
	int BuildingType2 = cUnitTypeArcheryRange;
	if (cMyCulture == cCultureEgyptian)
	{
		BuildingType1 = cUnitTypeBarracks;
		BuildingType2 = cUnitTypeBarracks;
	}
	if (cMyCulture == cCultureNorse)
	{
		BuildingType1 = cUnitTypeLonghouse;
		BuildingType2 = cUnitTypeLonghouse;
	}	   
	if (cMyCulture == cCultureAtlantean)
	{
		BuildingType1 = cUnitTypeBarracksAtlantean;
		BuildingType2 = cUnitTypeCounterBuilding;
	}
	if (cMyCulture == cCultureChinese)
	{
		BuildingType1 = cUnitTypeBarracksChinese;
		BuildingType2 = cUnitTypeStableChinese;
	}	   
	
	//Force barracks #1 to go down.
	int barracks1PlanID=aiPlanCreate("Barracks 1", cPlanBuild);
	if (barracks1PlanID >= 0)
	{
		aiPlanSetVariableInt(barracks1PlanID, cBuildPlanBuildingTypeID, 0, BuildingType1);
		aiPlanSetVariableBool(barracks1PlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
		aiPlanSetVariableFloat(barracks1PlanID, cBuildPlanRandomBPValue, 0, 0.0);
		
		fx = fzOrig * (-21);
		fz = fxOrig * 21;
		
		frontVector = xsVectorSetX(frontVector, fx);
		frontVector = xsVectorSetZ(frontVector, fz);
		frontVector = xsVectorSetY(frontVector, 0.0);
		location = origLocation + frontVector;
		
		aiPlanSetVariableVector(barracks1PlanID, cBuildPlanInfluencePosition, 0, location);
		aiPlanSetVariableFloat(barracks1PlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);
		aiPlanSetVariableFloat(barracks1PlanID, cBuildPlanInfluencePositionDistance, 0, 10.0);
		aiPlanSetVariableFloat(barracks1PlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
		
		aiPlanSetDesiredPriority(barracks1PlanID, 100);
		aiPlanAddUnitType(barracks1PlanID, BuilderType, 1, 1, 1);
		aiPlanSetEscrowID(barracks1PlanID, cMilitaryEscrowID);
		aiPlanSetBaseID(barracks1PlanID, kbBaseGetMainID(cMyID));
		aiPlanSetActive(barracks1PlanID);
	}
	
	//Force barracks #2 to go down.
	int barracks2PlanID=aiPlanCreate("Barracks 2", cPlanBuild);
	if (barracks2PlanID >= 0)
	{
		aiPlanSetVariableInt(barracks2PlanID, cBuildPlanBuildingTypeID, 0, BuildingType2);
		aiPlanSetVariableBool(barracks2PlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
		aiPlanSetVariableFloat(barracks2PlanID, cBuildPlanRandomBPValue, 0, 0.0);
		
		fx = fzOrig * 21;
		fz = fxOrig * (-21);
		
		frontVector = xsVectorSetX(frontVector, fx);
		frontVector = xsVectorSetZ(frontVector, fz);
		frontVector = xsVectorSetY(frontVector, 0.0);
		location = origLocation + frontVector;
		
		aiPlanSetVariableVector(barracks2PlanID, cBuildPlanInfluencePosition, 0, location);
		aiPlanSetVariableFloat(barracks2PlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);
		aiPlanSetVariableFloat(barracks2PlanID, cBuildPlanInfluencePositionDistance, 0, 10.0);
		aiPlanSetVariableFloat(barracks2PlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
		
		aiPlanSetDesiredPriority(barracks2PlanID, 100);
		aiPlanAddUnitType(barracks2PlanID, BuilderType, 1, 1, 1);
		aiPlanSetEscrowID(barracks2PlanID, cMilitaryEscrowID);
		aiPlanSetBaseID(barracks2PlanID, kbBaseGetMainID(cMyID));
		aiPlanSetActive(barracks2PlanID);
	}	
	
    //Build walls if we should.
    if (gBuildWalls == true)
    {
        if (gBuildWallsAtMainBase == true)
        {
            xsEnableRule("mainBaseAreaWallTeam1");
			xsEnableRule("MBSecondaryWall");
			
			
			if ((cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureGreek) || (cMyCulture == cCultureChinese))
			xsEnableRule("destroyUnnecessaryDropsites");
            
            if (aiGetGameMode() != cGameModeDeathmatch)
			xsEnableRule("setUnitPicker");
		}
        xsEnableRule("otherBaseRingWallTeam1");
        
        //start up the wall upgrades.
        xsEnableRule("getStoneWall");
        
	    if (cMyCulture == cCultureNorse)
        {
            //enable the norseInfantryBuild rule
            xsEnableRule("norseInfantryBuild");
		}
        
        //enable the rule to fix unfinished walls
        xsEnableRule("fixUnfinishedWalls");
        
        //enable the rule to destroy unnecessary dropsites near our mainbase
        if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureChinese))
		xsEnableRule("destroyUnnecessaryDropsites");
	}
    //build buildings at other bases
    xsEnableRule("buildBuildingsAtOtherBase");
	
    //build towers at other bases
    xsEnableRule("buildTowerAtOtherBase");  
	
    if (gRushCount <= 2)
    {
        //research age2 armor and weapon upgrades
        xsEnableRuleGroup("ArmoryAge2");
		
        //research age2 military upgrades
        if (cMyCulture == cCultureGreek)
        {
            xsEnableRuleGroup("mediumGreek");
		}
        else if (cMyCulture == cCultureEgyptian)
        {
            xsEnableRuleGroup("mediumEgyptian");
		}
        else if (cMyCulture == cCultureAtlantean)
        {
            xsEnableRule("getMediumCavalry");
            xsEnableRule("getMediumInfantry");
			xsEnableRule("getMediumArchers");
		}			
        else 
        {
            xsEnableRule("getMediumCavalry");
            xsEnableRule("getMediumInfantry");
		}
	}
    
    //research heroic fleet on transport maps
    if (gTransportMap == true)
	xsEnableRule("getHeroicFleet");
	
    //research masons
    xsEnableRule("getMasons");
	
    //enable the rebuildDropsites rule for Greeks, Egyptians and chinese.
    if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureChinese))
	xsEnableRule("rebuildDropsites");
    
    //enable the buildGoldMineTower rule
    xsEnableRule("buildGoldMineTower");
	
	if (cMyCiv == cCivNuwa)
	{
		//We can trade now.
		xsEnableRule("tradeWithCaravans");
		tradeWithCaravans();
		xsEnableRule("maintainTradeUnits");
		xsEnableRule("sendIdleTradeUnitsToRandomBase");	
	}	
}

//==============================================================================
void age3Handler(int age=2)
{
    gLastAgeHandled = cAge3;
    if (cvMaxAge == age)
    {
        aiSetPauseAllAgeUpgrades(true);
	}
    //Econ.
    econAge3Handler(age);
    //Progress.
    progressAge3Handler(age);
    //GP.
    gpAge3Handler(age);
    //Naval
    navalAge3Handler(age);
	
    //kill the rush goals
    if (gRushGoalID != -1)
	aiPlanDestroy(gRushGoalID);
    if (gIdleAttackGID != -1)
	aiPlanDestroy(gIdleAttackGID);
    
    // build as many fortresses as possible 
    xsEnableRule("buildFortress");
	
	if ((aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch))
    xsEnableRule("watchForFirstWonderStart");
	
	if (cMyCulture != cCultureNorse)
	xsEnableRule("getGuardTower");  
	xsEnableRule("getBoilingOil");

    //Switch the EM rule.
    updateEMAllAges();
	
    //Up the number of water transports to maintain.
    if (gMaintainWaterXPortPlanID >= 0)
	aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 2);
	
    //Create new greek hero maintain plans.
    if (cMyCulture == cCultureGreek)
    {
        xsEnableRuleGroup("techsGreekMinorGodAge3");
        if (cMyCiv == cCivZeus)
		gHero3MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekHeracles, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivPoseidon)
		gHero3MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekAtalanta, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivHades)
		gHero3MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekAchilles, 1, false, kbBaseGetMainID(cMyID));
        
        aiPlanSetDesiredPriority(gHero3MaintainPlan, 100);
	}
    else if (cMyCulture == cCultureEgyptian)
    {
        xsEnableRule("decreaseRaxPref"); 
        aiSetMaxLOSProtoUnitLimit(9);
	}
    else if (cMyCulture == cCultureNorse)
    {
        //research axe of muspell
        xsEnableRule("getAxeOfMuspell");
	}
	
	
    // Build a fortress/palace/whatever...or 4 in DM
    int buildingType = MyFortress;
    int numBuilders = 1;
    switch(cMyCulture)
    {
        case cCultureGreek:
        {
            numBuilders = 4;
            break;
		}
        case cCultureEgyptian:
        {
            numBuilders = 5;
            break;
		}
        case cCultureNorse:
        {
            numBuilders = 3;
            break;
		}
        case cCultureAtlantean:
        {
            numBuilders = 1;
            break;
		}
        case cCultureChinese:
        {
            numBuilders = 4;
            break;
		}		
	}
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
	builderType = cUnitTypeAbstractInfantry;
	
    int strongBuildPlanID=aiPlanCreate("Build Strong Building ", cPlanBuild);
    if (strongBuildPlanID >= 0)
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, kbBaseGetMainID(cMyID));
        
        float x = xsVectorGetX(frontVector);
        float z = xsVectorGetZ(frontVector);
		
        x = x * 15;
        z = z * 15;
		
        frontVector = xsVectorSetX(frontVector, x);
        frontVector = xsVectorSetZ(frontVector, z);
        frontVector = xsVectorSetY(frontVector, 0.0);
        vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
        location = location + frontVector;
        
        aiPlanSetInitialPosition(strongBuildPlanID, location);
        aiPlanSetVariableBool(strongBuildPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(strongBuildPlanID, cBuildPlanRandomBPValue, 0, 0.99);
        aiPlanSetVariableVector(strongBuildPlanID, cBuildPlanInfluencePosition, 0, location);
        aiPlanSetVariableFloat(strongBuildPlanID, cBuildPlanInfluencePositionDistance, 0, 40.0);
        aiPlanSetVariableFloat(strongBuildPlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
        
        aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
        aiPlanSetDesiredPriority(strongBuildPlanID, 100);
        aiPlanAddUnitType(strongBuildPlanID, builderType, numBuilders, numBuilders, numBuilders);
        aiPlanSetEscrowID(strongBuildPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(strongBuildPlanID, kbBaseGetMainID(cMyID));
        aiPlanSetActive(strongBuildPlanID);
	}
	
	if (cMyCiv != cCivNuwa)
	{
		xsEnableRule("tradeWithCaravans");
		tradeWithCaravans();
		xsEnableRule("maintainTradeUnits");
		xsEnableRule("sendIdleTradeUnitsToRandomBase");	
	}
	
    //get tax collectors and ambassadors
    xsEnableRule("getTaxCollectors");  
    xsEnableRule("getAmbassadors"); //AI is indeed taxed too!
	
    //enable the tacticalSiege rule
    xsEnableRule("tacticalSiege");
    //enable the getDraftHorses rule
    xsEnableRule("getDraftHorses");
    //enable the maintainSiegeUnits rule
    xsEnableRule("maintainSiegeUnits");
    
    //enable the age2 military tech rules to make sure they get researched
    if (gRushCount > 2)
    {
        if (cMyCulture == cCultureGreek)
        {
            xsEnableRuleGroup("mediumGreek");
		}
        else if (cMyCulture == cCultureEgyptian)
        {
            xsEnableRuleGroup("mediumEgyptian");
		}
        else if ((cMyCulture == cCultureNorse) || (cMyCulture == cCultureChinese))
        {
            xsEnableRule("getMediumCavalry");
            xsEnableRule("getMediumInfantry");
		}
        else if (cMyCulture == cCultureAtlantean)
        {
            xsEnableRule("getMediumCavalry");
            xsEnableRule("getMediumInfantry");
			xsEnableRule("getMediumArchers");
		}	
	}
}

//==============================================================================
void age4Handler(int age=3)
{
    if (cvMaxAge == age)
    {
        aiSetPauseAllAgeUpgrades(true);
	}
    gLastAgeHandled = cAge4;
    //Econ.
    econAge4Handler(age);
    //Progress.
    progressAge4Handler(age);
    //GP.
    gpAge4Handler(age);
	
    if ( (aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch) )
	xsEnableRule("makeWonder");      // Make a wonder if you have spare resources
	
    //Switch the EM rule.
    updateEMAllAges();
    
    //Enable our omniscience rule.
    xsEnableRule("getOmniscience");
	
    // Get trade unit speed upgrade
    xsEnableRule("getCoinage");
	
    //Econ.
	
    //Create new greek hero maintain plans.
    if (cMyCulture == cCultureGreek)
    {
        xsEnableRule("getBeastSlayer");
        if (cMyCiv == cCivZeus)
		gHero4MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekBellerophon, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivPoseidon)
		gHero4MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekPolyphemus, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivHades)
		gHero4MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekPerseus, 1, false, kbBaseGetMainID(cMyID));
		
        aiPlanSetDesiredPriority(gHero4MaintainPlan, 100);
		
        if (aiGetWorldDifficulty() != cDifficultyEasy)
		createSimpleMaintainPlan(cUnitTypeHelepolis, 1, false, kbBaseGetMainID(cMyID));
		
        //research god specific tech upgrades
        xsEnableRuleGroup("techsGreekMinorGodAge4");
        
        if (gAge4MinorGod == cTechAge4Hephaestus)
        {
            xsEnableRuleGroup("championGreek"); //because we set the attack goal to idle until cTechForgeofOlympus is researched
		}
	}
    else if (cMyCulture == cCultureAtlantean)
    {
        if (gAge4MinorGod == cTechAge4Helios)
        {
            xsEnableRule("buildMirrorTower");
		}
	}
	else if (cMyCulture == cCultureEgyptian)
	aiSetMaxLOSProtoUnitLimit(11);
    
	
    //If we're in deathmatch, no more hard pop cap.
    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        gHardEconomyPopCap=-1;
        kbEscrowAllocateCurrentResources();
	}
	
    // if we are on a land map or playing conquest make titan
    if ((gTransportMap == false) || (aiGetGameMode() == cGameModeConquest))
    {
        xsEnableRule("getSecretsOfTheTitan");
	}

    //set the lateUPID to 3 unit types and 3 buildings.
    if (aiGetGameMode() != cGameModeDeathmatch)
	kbUnitPickSetDesiredNumberUnitTypes(gLateUPID, 3, 3, true);
	
    //enable the getEngineers rule
    xsEnableRule("getEngineers");
}

//==============================================================================
void age5Handler(int age=4)
{
    gLastAgeHandled = cAge5;
	
	// Set Escrow back to normal.
	kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 300.0);    
    kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 300.0);    
    if (cMyCulture == cCultureEgyptian)
    kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 400.0);
	else
    kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 300.0);   
    kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 30.0);
	//
	
	//enable the titanplacement rule
    xsEnableRule("rPlaceTitanGate");
    //enable the randomUpgrader rule
    xsEnableRule("randomUpgrader");
}


//==============================================================================
rule ShouldIResign
minInterval 53 //starts in cAge1
active
{
    if (ShowAiEcho == true) aiEcho("ShouldIResign:");
	
    if (cvOkToResign == false)
    {
        xsDisableSelf();     // Must be re-enabled if cvOkToResign is set true.
        return;     
	}
	
    //Don't resign too soon.
    if (xsGetTime() < 10*60*1000)
	return;
	
    //Don't resign if you're teamed with a human.
    static bool checkTeamedWithHuman=true;
    if (checkTeamedWithHuman == true)
    {
        for (i=1; < cNumberPlayers)
        {
            if (i == cMyID)
			continue;
            //Skip if not human.
            if (kbIsPlayerHuman(i) == false)
			continue;
            //If this is a mutually allied human, go away.
            if (kbIsPlayerMutualAlly(i) == true)
            {
                xsDisableSelf();
                return;
			}
		}
        //Don't check again.
        checkTeamedWithHuman=false;
	}
	
	if ((cMyCulture == cCultureNorse) && (IhaveAllies == true))
	{
		int NorseBuilders=kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);
		int NorseTotalMilBuildings=kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsThatTrainMilitary,  cUnitStateAlive);
		if ((NorseBuilders > 0) || (NorseTotalMilBuildings > 0) && (kbGetPopCap() > 0))
		return;
	}
	
	
    int numSettlements=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    //If on easy, don't only resign if you have no settlements.
    if (aiGetWorldDifficulty() == cDifficultyEasy)
    {
        if (numSettlements <= 0)
        {
            gResignType = cResignSettlements;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
		}
        return;
	}
	
    //Don't resign if we have over 30 active pop slots.
    if (kbGetPop() >= 30)
	return;
	
    //Don't quit if we have at least one settlement.
    if ((numSettlements > 1) || (numSettlements > 0) && (IhaveAllies == true))
	return;
    
	//Don't resign if we still have villagers and teamed up.
	int numAliveVils=kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	if ((numAliveVils > 0) && (IhaveAllies == true))
	return;
	
	
    int builderUnitID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
    int numBuilders=kbUnitCount(cMyID, builderUnitID, cUnitStateAliveOrBuilding);   
	
    if ((numSettlements <= 0) && (numBuilders <= 10))
    {
        if (kbCanAffordUnit(cUnitTypeSettlementLevel1, cEconomyEscrowID) == false)
        {
            gResignType = cResignSettlements;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
		}
	}
    //If we don't have any builders, we're not Norse, and we cannot afford anymore, try to resign.
    if ((numBuilders <= 0) && (cMyCulture != cCultureNorse))
    {
        if (kbCanAffordUnit(builderUnitID, cEconomyEscrowID) == false)
        {
            gResignType=cResignGatherers;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
		}
	}
	
	
    //3. if all of my teammates have left the game.
    int activeEnemies=0;
    int activeTeammates=0;
    int deadTeammates=0;
    float currentEnemyMilPop=0.0;
    float currentMilPop=0.0;
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
        {
            currentMilPop=currentMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
            continue;
		}
		
        if (kbIsPlayerAlly(i) == false)
        {
            //Increment the active number of enemies there currently are.
            if (kbIsPlayerResigned(i) == false)
            {
                activeEnemies=activeEnemies+1;
                currentEnemyMilPop=currentEnemyMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
			}
            continue;
		}
		
        //If I still have an active teammate, don't resign.
        if (kbIsPlayerResigned(i) == true)
		deadTeammates=deadTeammates+1;
        else
		activeTeammates=activeTeammates+1;
	}
	
    //3a. if at least one player from my team has left the game and I am the only player left on my team, 
    //    and the other team(s) have 2 or more players in the game.
    if ((activeEnemies >= 2) && (activeTeammates <= 0) && (deadTeammates>0))
    {
        gResignType=cResignTeammates;
        aiAttemptResign(cAICommPromptResignQuestion);
        xsDisableSelf();
        return;
	}
	
    //4. my mil pop is low and the enemy's mil pop is high,
    //Don't do this eval until 4th age and at least 30 min. into the game.
    if ((xsGetTime() < 30*60*1000) || (kbGetAge() < cAge4))
	return;
	
    static float enemyMilPopTotal=0.0;
    static float myMilPopTotal=0.0;
    static float count=0.0;
    count=count+1.0;
    enemyMilPopTotal=enemyMilPopTotal+currentEnemyMilPop;
    myMilPopTotal=myMilPopTotal+currentMilPop;
    if (count >= 10.0)
    {
        if ((enemyMilPopTotal > (7.0*myMilPopTotal)) || (myMilPopTotal <= count))
        {
			
            gResignType=cResignMilitaryPop;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
		}
		
        count=0.0;
        enemyMilPopTotal=0.0;
        myMilPopTotal=0.0;
	}
}

//==============================================================================
void resignHandler(int result =-1)
{
    if (result == 0)
    {
        return;
	}
	
    if (gResignType == cResignGatherers)
    {
        aiResign();
        return;
	}
    if (gResignType == cResignSettlements)
    {
        aiResign();
        return;
	}
    if (gResignType == cResignTeammates)
    {
        aiResign();
        return;
	}
    if (gResignType == cResignMilitaryPop)
    {
        aiResign();
        return;
	}
}

//==============================================================================
rule findFish   //We don't know if this is a water map...if you see fish, it is.
minInterval 1 //starts in cAge1
active
{
	xsSetRuleMinIntervalSelf(25);
	
	if (ShowAiEcho == true) aiEcho("findFish:");
	if (xsGetTime() > 1*30*1000)  // Disable if we've tried for too long.
	xsDisableSelf();
	
	// Disable early fishing for Nomad & Highland, to later be enabled.
	
	if ((cRandomMapName == "highland") || (cRandomMapName == "nomad") ||(NoFishing == true) || (cvMapSubType == VINLANDSAGAMAP))
	{
		if (ShowAiEcho == true) aiEcho("FindFish disabled, map forced this.");
		xsDisableSelf();
		return;
	}
	
	
    if (kbUnitCount(0, cUnitTypeFish) > 0)
    {
        gWaterMap=true;
        //Tell the AI what kind of map we are on.
        aiSetWaterMap(gWaterMap);
        xsEnableRule("fishing");
        //Fire up.
        if (gMaintainWaterXPortPlanID < 0 && gTransportMap == true) 
        gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 1, false, -1);
		
        xsDisableSelf();
	}
}

//==============================================================================
rule watchForFirstWonderStart   //Look for any wonder being built.  If found, activate
//the high-speed rule that watches for completion
minInterval 73 //starts in cAge3    // Hopefully nobody will build one faster than this
inactive
{
    if (ShowAiEcho == true) aiEcho("watchForFirstWonderStart:");
    xsSetRuleMinIntervalSelf(73);
    static int wonderQueryStart = -1;
    if (wonderQueryStart < 0)
    {
        wonderQueryStart = kbUnitQueryCreate("Start wonder query");
        if ( wonderQueryStart == -1)
        {
            xsDisableSelf();
            return;
		}
        kbUnitQuerySetPlayerRelation(wonderQueryStart, cPlayerRelationAny);
        kbUnitQuerySetUnitType(wonderQueryStart, cUnitTypeWonder);
        kbUnitQuerySetState(wonderQueryStart, cUnitStateAliveOrBuilding);     // Any wonder under construction
	}
	
    kbUnitQueryResetResults(wonderQueryStart);
    if (kbUnitQueryExecute(wonderQueryStart) > 0)
    {
        if (ShowAiEcho == true) aiEcho("**** Someone is building a wonder!");
        xsDisableSelf();
        xsEnableRule("watchForFirstWonderDone");
	}
}

//==============================================================================
rule watchForFirstWonderDone    //See who makes the first wonder, note its ID, make a defend
//plan to kill it, kill defend plan when it's gone
inactive
minInterval 7 //starts in cAge3 activated in watchForFirstWonderStart
{
    if (ShowAiEcho == true) aiEcho("watchForFirstWonderDone:");
    
    static int enemyWonderQuery = -1;
    static int wonderID = -1;
    static vector wonderLocation = cInvalidVector;
	
    if (enemyWonderQuery < 0)
    {
        enemyWonderQuery = kbUnitQueryCreate("enemy wonder query");
        if ( enemyWonderQuery == -1)
        {
            xsDisableSelf();
            return;
		}
        kbUnitQuerySetPlayerRelation(enemyWonderQuery, cPlayerRelationEnemy);
        kbUnitQuerySetUnitType(enemyWonderQuery, cUnitTypeWonder);
        kbUnitQuerySetState(enemyWonderQuery, cUnitStateAlive);     // Only completed wonders count
	}
    
    static int allyWonderQuery = -1;
    if (allyWonderQuery < 0)
    {
        allyWonderQuery = kbUnitQueryCreate("ally wonder query");
        if ( allyWonderQuery == -1)
        {
            xsDisableSelf();
            return;
		}
        kbUnitQuerySetPlayerRelation(allyWonderQuery, cPlayerRelationAlly);
        kbUnitQuerySetUnitType(allyWonderQuery, cUnitTypeWonder);
        kbUnitQuerySetState(allyWonderQuery, cUnitStateAlive);     // Only completed wonders count
	}
	
    static int myWonderQuery = -1;
    if (myWonderQuery < 0)
    {
        myWonderQuery = kbUnitQueryCreate("my wonder query");
        if ( myWonderQuery == -1)
        {
            xsDisableSelf();
            return;
		}
        kbUnitQuerySetPlayerRelation(myWonderQuery, cPlayerRelationSelf);
        kbUnitQuerySetUnitType(myWonderQuery, cUnitTypeWonder);
        kbUnitQuerySetState(myWonderQuery, cUnitStateAlive);     // Only completed wonders count
	}
    static int wonderDefendPlanStartTime = -1;
	
    if (wonderID < 0) // No wonder has been built, look for them
    {
        kbUnitQueryResetResults(myWonderQuery);
        if (kbUnitQueryExecute(myWonderQuery) > 0)   // I win, quit.
		return;
		
        kbUnitQueryResetResults(enemyWonderQuery);
        if (kbUnitQueryExecute(enemyWonderQuery) > 0)
        {
            // Create highest-priority defend plan to go kill it
            wonderID = kbUnitQueryGetResult(enemyWonderQuery, 0);
            wonderLocation = kbUnitGetPosition(wonderID);
			
            // Making an attack plan instead, they do a better job of transporting and ignoring some targets en route.
            gEnemyWonderDefendPlan=createDefOrAttackPlan("Enemy wonder attack plan", false, -1, 60, cInvalidVector, -1, 60, false);
            if (gEnemyWonderDefendPlan < 0)
			return;
            int n=0;
            for (n=1; <= cNumberPlayers)
            {
                if (kbUnitCount(n, cUnitTypeWonder, cUnitStateAlive) > 0)
                {
                    aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanPlayerID, 0, n);
				}
			}
			
            // Specify other continent so that armies will transport
            aiPlanSetNumberVariableValues( gEnemyWonderDefendPlan, cAttackPlanTargetAreaGroups,  1, true);  
            aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(kbUnitGetPosition(wonderID)));
            aiPlanSetVariableVector(gEnemyWonderDefendPlan, cAttackPlanGatherPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
            
            aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeLogicalTypeLandMilitary, 200, 200, 200);
            aiPlanSetInitialPosition(gEnemyWonderDefendPlan, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
			
            aiPlanSetVariableBool(gEnemyWonderDefendPlan, cAttackPlanAutoUseGPs, 0, true);
            aiPlanSetVariableBool(gEnemyWonderDefendPlan, cAttackPlanMoveAttack, 0, true);
            aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanSpecificTargetID, 0, wonderID);
            
            wonderDefendPlanStartTime = xsGetTime();
            aiPlanSetActive(gEnemyWonderDefendPlan);
            if (ShowAiEcho == true) aiEcho("Creating enemy wonder attack plan");
		}
        else
        {
            kbUnitQueryResetResults(allyWonderQuery);
            if (kbUnitQueryExecute(allyWonderQuery) > 0)
            {
                // Create highest-priority defend plan to go protect it
                wonderID = kbUnitQueryGetResult(allyWonderQuery, 0);
                wonderLocation = kbUnitGetPosition(wonderID);
                if ( kbAreaGroupGetIDByPosition(wonderLocation) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) )
                {  // It's on my continent, go help
                    gEnemyWonderDefendPlan = createDefOrAttackPlan("Ally Wonder Defend Plan", true, 60, 40, wonderLocation, -1, 96, false);
                    if (gEnemyWonderDefendPlan >= 0)
                    {
                        aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeMilitary, 200, 200, 200);    // All mil units
                        wonderDefendPlanStartTime = xsGetTime();
                        aiPlanSetActive(gEnemyWonderDefendPlan);
                        if (ShowAiEcho == true) aiEcho("Creating ally wonder defend plan");
					}
				}
			}
		}
	}
    else  // A wonder was built...if it's down, kill the uber-plan
    {
        if (aiPlanGetState(gEnemyWonderDefendPlan) == cPlanStateAttack)
		aiPlanSetNoMoreUnits(gEnemyWonderDefendPlan, false);  // Make sure the enemy wonder 'defend' plan stays open
        
        if (kbUnitGetCurrentHitpoints(wonderID) <= 0)
        {
            aiPlanDestroy(gEnemyWonderDefendPlan);
            gEnemyWonderDefendPlan = -1;
			xsSetRuleMinInterval("watchForFirstWonderStart", 2);
			xsEnableRule("watchForFirstWonderStart");
            xsDisableSelf();
		}
	}
}

//==============================================================================
rule watchForWonder  // See if my wonder has been placed.  If so, go build it.
minInterval 23 //starts in cAge4, activated in make wonder
inactive
{
    if (ShowAiEcho == true) aiEcho("watchForWonder:");
    
    if ( kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) < 1 )
	return;
	
    xsEnableRule("watchWonderLost");    // Kill the defend plan if the wonder is destroyed.
	
    int wonderID = findUnit(cUnitTypeWonder, cUnitStateAliveOrBuilding);
    vector wonderLocation = kbUnitGetPosition(wonderID);
	
    // Make the defend plan
    gWonderDefendPlan = createDefOrAttackPlan("Wonder Defend Plan", true, 60, 40, wonderLocation, -1, 95, false);
    if (gWonderDefendPlan >= 0)
    {
        aiPlanAddUnitType(gWonderDefendPlan, cUnitTypeMilitary, 20, 200, 200);    // most mil units
        aiPlanSetActive(gWonderDefendPlan); 
        if (ShowAiEcho == true) aiEcho("Creating wonder defend plan");    
	}
	
    // we have a wonder, get a titan
    xsEnableRule("getSecretsOfTheTitan");
	
    xsDisableSelf();
}

//==============================================================================
rule watchWonderLost    // Kill the uber-defend plan if wonder falls
minInterval 7 //starts in cAge4, activated in watchForWonder
inactive
{
    if (ShowAiEcho == true) aiEcho("watchWonderLost:");
    
    if ( kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) > 0 )
	return;
	
    aiPlanDestroy(gWonderDefendPlan);
    xsEnableRule("makeWonder");      // Try again if we get a chance
    xsDisableSelf();
}

//==============================================================================
rule goAndGatherRelics
inactive
minInterval 101 //starts in cAge1
{
    static int gatherRelicStartTime = -1;
	
	int EgyTempleUp = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
	if (EgyTempleUp < 1 && cMyCulture == cCultureEgyptian)
	{
		if (ShowAiEcho == true) aiEcho("No! I will not make my pharaoh get stuck in my temple again!");
		return;
	}
    if (ShowAiEcho == true) aiEcho("gatherRelicStartTime "+gatherRelicStartTime);
    
    int numRelicGatherers = kbUnitCount(cMyID, gGatherRelicType, cUnitStateAlive);
    if ((numRelicGatherers < 1) && (xsGetTime() < 5*60*1000))
	return;
    
    int activeGatherRelicPlans = aiPlanGetNumber(cPlanGatherRelic, -1, true);
    if (activeGatherRelicPlans > 0)
    {
        if (xsGetTime() > gatherRelicStartTime + 10*60*1000)
        {
            aiPlanDestroy(gRelicGatherPlanID);
            gRelicGatherPlanID = -1;
            gatherRelicStartTime = -1;
            xsSetRuleMinIntervalSelf(101);
            if (ShowAiEcho == true) aiEcho("destroying gRelicGatherPlanID as it has been active for more than 10 minutes");
            return;
		}
        else
        {
            if (ShowAiEcho == true) aiEcho("activeGatherRelicPlans > 0, returning");
            return;
		}
	}
	
    if (cMyCulture == cCultureEgyptian)
    {
        if (kbGetTechStatus(cTechHandsofthePharaoh) == cTechStatusActive)
        {
            gGatherRelicType = cUnitTypePriest;
            if (ShowAiEcho == true) aiEcho("cTechHandsofthePharaoh == active, gGatherRelicType = "+gGatherRelicType);
		}
        else
		if (ShowAiEcho == true) aiEcho("cTechHandsofthePharaoh is not active, gGatherRelicType = "+gGatherRelicType);
	}
    
    if (ShowAiEcho == true) aiEcho("Creating relic gathering plan with unit type "+gGatherRelicType);
    gRelicGatherPlanID = aiPlanCreate("Relic Gather", cPlanGatherRelic);
	
    if (gRelicGatherPlanID >= 0)
    {
        aiPlanAddUnitType(gRelicGatherPlanID, gGatherRelicType, 1, 1, 1);
        aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanTargetTypeID, 0, cUnitTypeRelic);
        aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanDropsiteTypeID, 0, cUnitTypeTemple);
        aiPlanSetBaseID(gRelicGatherPlanID, kbBaseGetMainID(cMyID));
        aiPlanSetDesiredPriority(gRelicGatherPlanID, 100);
        aiPlanSetActive(gRelicGatherPlanID);
        if (ShowAiEcho == true) aiEcho("gRelicGatherPlanID: "+gRelicGatherPlanID);
        xsSetRuleMinIntervalSelf(307);
        gatherRelicStartTime = xsGetTime();
        if (ShowAiEcho == true) aiEcho("gatherRelicStartTime "+gatherRelicStartTime);
	}
}

//==============================================================================
rule relicUnitHandler
minInterval 127 //starts in cAge1
inactive
{  
    if (ShowAiEcho == true) aiEcho("relicUnitHandler:");
	
    int numPegasus = kbUnitCount(cMyID, cUnitTypePegasus, cUnitStateAlive);   
	
    if (numPegasus > 0)
    {
        int exploreID = aiPlanCreate("RelicPegasus_Exp", cPlanExplore);
        if (exploreID >= 0)
        {
            if (ShowAiEcho == true) aiEcho("Pegasus Relic detected : Setting up Pegasus explore plan.");
            aiPlanAddUnitType(exploreID, cUnitTypePegasus, 1, 1, 1);
            aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetDesiredPriority(exploreID, 98);
            aiPlanSetEscrowID(exploreID, cEconomyEscrowID);
            aiPlanSetActive(exploreID);
		}
        xsDisableSelf();
	}
}

//==============================================================================
rule spotAgeUpgrades    //detect age upgrades given as starting conditions or via triggers
minInterval 18 //starts in cAge1
inactive
{
    if (ShowAiEcho == true) aiEcho("spotAgeUpgrades:");
    
    if ( gLastAgeHandled < kbGetAge() )    // If my current age is higher than the last upgrade I remember...do the handler
    {
        if (gLastAgeHandled == cAge1)
        {
            age2Handler();
            return;
		}
        else if (gLastAgeHandled == cAge2)
        {
            age3Handler();
            return;
		}
        else if (gLastAgeHandled == cAge3)
        {
            age4Handler();
            return;
		}
        else if (gLastAgeHandled == cAge4)
        {
            age5Handler();
            xsDisableSelf();
		}
	}
}
//==============================================================================
void main(void)
{
    //Set our random seed.  "-1" is a random init.
    aiRandSetSeed(-1);
	
    //Calculate some areas.
    kbAreaCalculate();
	
    preInitMap();
    persDecidePersonality();     // Set the control variables before anything else
	
    //Go.
    if (cvDelayStart != true)
	init();
    else
	xsDisableRule("age1Progress");
}
//==============================================================================
// god power handler
//==============================================================================
void gpHandler(int powerProtoID=-1)
{ 
	if (powerProtoID == -1)
	return;
	if (powerProtoID == cPowerSpy)
	return;
	
	//Most hated player chats.
	if ((powerProtoID == cPowerPlagueofSerpents) ||
	(powerProtoID == cPowerEarthquake)        ||
	(powerProtoID == cPowerCurse)             ||
	(powerProtoID == cPowerFlamingWeapons)    || 
	(powerProtoID == cPowerForestFire)        ||
	(powerProtoID == cPowerFrost)             ||
	(powerProtoID == cPowerLightningStorm)    ||
	(powerProtoID == cPowerLocustSwarm)       ||
	(powerProtoID == cPowerMeteor)            ||
	(powerProtoID == cPowerAncestors)         ||
	(powerProtoID == cPowerFimbulwinter)      ||
	(powerProtoID == cPowerTornado)           ||
	(powerProtoID == cPowerBolt))
	{
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptOffensiveGodPower, -1);
		return;
	}
	
	//Any player chats.
	int type=cAICommPromptGenericGodPower;
	if ((powerProtoID == cPowerProsperity) || 
	(powerProtoID == cPowerPlenty)      ||
	(powerProtoID == cPowerLure)        ||
	(powerProtoID == cPowerDwarvenMine) ||
	(powerProtoID == cPowerGreatHunt)   ||
	(powerProtoID == cPowerRain))
	{
		type=cAICommPromptEconomicGodPower;
	}
    // If the power is TitanGate, then we need to launch the repair plan to build it..
    if (powerProtoID == cPowerTitanGate)
    {
        // Don't look for it now, just set up the rule that looks for it
        // and then launches a repair plan to build it. 
        xsEnableRule("repairTitanGate");
        return;
	}
	//Tell all the enemy players
	for (i=1; < cNumberPlayers)
	{
		if (i == cMyID)
		continue;
		if (kbIsPlayerAlly(i) == true)
		continue;
		aiCommsSendStatement(i, type, -1);
	}
}