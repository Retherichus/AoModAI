//File: AoModAiExtra.xs
//By Retherichus
//I'm so happy that you made it this far! this is where you'll find some of the code I've added to the Ai.
//I do plan on putting every change into this file eventually... 
//but that ain't so easy, so there's still some code lurking around in the other files.
//Feel free to copy/borrow my stuff for your own projects if you like, though some credit would be appreciated!
//Oh.. and suggestions are very welcome too.
//
//Now.. if you're just looking to enable/disable stuff, skip to "PART 2". (:


//==============================================================================
//PART 1 Int & Handler
//Below, you'll find the external calls and Plan handlers. 
//you don't really want to touch this.. and if you do, you'll break stuff.
//==============================================================================
extern int fCitadelPlanID = -1;
extern bool AutoDetectMap = false;
extern bool NeedTransportCheck = false;
extern int gShiftingSandPlanID= -1;
mutable void wonderDeathHandler(int playerID=-1) { }
extern bool gHuntingDogsASAP = false;     // Will automatically be called upon if there is hunt nearby the MB.
extern bool RiverSLowBoar = false;
extern bool RetardedLowBoarSpawn = false;
extern bool gpDelayMigration = false;
extern int gGardenBuildLimit = 0;
extern int wonderBPID = -1;
extern bool IsRunHuntingDogs = false;
extern int gDefendPlentyVault = -1;
extern int gHeavyGPTech=-1;
extern int gHeavyGPPlan=-1;
extern int gDefendPlentyVaultWater=-1;
extern int WallAllyPlanID=-1;
extern int FailedToTrain = 0;
extern int defWantedCaravans = 22;
extern bool KOTHStopRefill = false;
extern vector KOTHGlobal = cInvalidVector;
extern bool IhaveAllies = false;
extern bool mRusher = false;
extern bool BeenmRusher = false;
extern int MoreFarms = 26;
extern bool TitanAvailable = false;
extern bool KoTHWaterVersion = false;
extern int KOTHBASE = -1;
extern bool KothDefPlanActive = false;
extern bool WaitForDock = false;
extern int mChineseImmortal = -1;
extern int eChineseHero = -1;
extern int cMonkMaintain = -1;
extern int StuckTransformID = 0;
extern int ResourceBaseID = -1;
extern bool HasHumanAlly = false;
extern int gExaminationID = -1;
extern int MigrationAreaID = -1;
extern int gSomeData = -1;
extern bool AoModAllies = false;
extern const int Tellothers = 30;
extern const int admiralTellothers = 31;
extern const int AttackTarget = 35;
extern const int cAttackTC = 36;
extern int aEnemyTCID = -1;
extern int aLastTCIDTime = 0;
extern const int cEmergency = 38;
extern const int cLowPriority = 39;
extern const int VectorData = 40;
extern bool ChangeMHP = false;
extern int MHPTime = 0;
extern const int INeedHelp = 32;
extern int HelpSettleID = -1;
extern const int Yes = 60;
extern const int No = 61;
extern int gLastSentTime = 0;
extern const int RequestFood = 70;
extern const int RequestWood = 71;
extern const int RequestGold = 72;
extern const int ExtraFood = 73;
extern const int ExtraWood = 74;
extern const int ExtraGold = 75;
extern const int RequestTower = 76;
extern const int EcoPercentage = 80;
extern const int MilPercentage = 81;
extern const int RootPercentage = 82;
extern const int LandAttackTarget = 85;
extern const int SettlementAttackTarget = 86;
extern const int MainUnit = 87;
extern const int SecondaryUnit = 88;
extern const int ThirdUnit = 89;
extern const int PlayersData = 100;

//////////////// aiEchoDEBUG ////////////////
extern bool ShowAiEcho = false; // All aiEcho, see specific below to override.
extern bool ShowAIComms = false;
//////////////// END OF aiEchoDEBUG ///////////

//==============================================================================
//PART 2 Bools & Stuff you can change!
//Below, you'll find a few things I've set up,
//you can turn these on/off as you please, by setting the final value to "true" (on) or "false" (off).
//There's also a small description on all of them, to make it a little easier to understand what happens when you set it to true.
//==============================================================================
extern bool mCanIDefendAllies = true;     // Allows the AI to defend his allies.
extern bool gWallsInDM = true;            // This allows the Ai to build walls in the game mode ''Deathmatch''.
extern bool gAgeReduceMil = false;         // This will lower the amount of military units the AI will train until Mythic Age, this will also help the AI to advance a little bit faster, more configs below.
extern bool bWallUp = true;              // This ensures that the Ai will build walls, regardless of personality.

extern bool CanIChat = true;              // This will allow the Ai to send chat messages, such as asking for help if it's in danger.
extern bool bHouseBunkering = true;       // Makes the Ai bunker up towers with Houses.
extern bool bWallAllyMB = true;          // Walls up TCs for human allies, only the team captain can do this and MBs are skipped.
extern bool bWallCleanup = true;          // Prevents the AI from building small wall pieces inside of gates and/or deletes them if one were to slip through the check.

//For gAgeReduceMil when true.
extern int eMaxMilPop = 15;               // Max military pop cap during Classical Age, the lower it is, the faster it'll advance, but leaving it defenseless can be just as bad!
extern int eHMaxMilPop = 25;              // Heroic age.


//STINNERV Stuff, or rather what's left of it.
extern int mGoldBeforeTrade = 6500;       //Excess gold to other resources, (All modes).
extern bool DisallowPullBack = false;  // set true to make the AI no longer retreat(All modes).
// End of STINNERV

//==============================================================================
//PART 3 Overrides & Rules
//From here and below, you'll find my custom rules, 
//as well with some ''Handlers/Overrides'' if we could call it that.
//==============================================================================


//==============================================================================
// Comms  // taken from Noton <3, patched to use the EventHandler instead. 
//==============================================================================

//==============================================================================
bool MessageRel(int cPlayerRelation = -1, int Prompt = -1, int Other = -1, vector location = cInvalidVector)
{
	bool Success = false;         
	switch(cPlayerRelation)
	{
		case cPlayerRelationAlly:
		{
			for (i=0; < cNumberPlayers)
			{
				if (i == cMyID)
				continue;
				if ((kbIsPlayerMutualAlly(i) == true) && (kbIsPlayerResigned(i) == false) && 
				(kbIsPlayerValid(i) == true) && (kbHasPlayerLost(i) == false) && (kbIsPlayerHuman(i) == false))
				{
				    if (Other == VectorData)
					aiCommsSendOrderWithVector(i, Prompt, VectorData, location);
				    else
					aiCommsSendOrder(i, Prompt, Other);
					Success = true;
				}		  
			}	   
		}
	}
	if (Success == true)
	return(true);
	else
	return(false);
}

//==============================================================================
bool MessagePlayer(int PlayerID = -1, int Prompt = -1, int Other = -1, vector location = cInvalidVector)
{
	bool Success = false;         
	if ((PlayerID == cMyID) || (PlayerID <= 0))
	return(false);

	if ((kbIsPlayerMutualAlly(PlayerID) == true) && (kbIsPlayerResigned(PlayerID) == false) && 
	(kbIsPlayerValid(PlayerID) == true) && (kbHasPlayerLost(PlayerID) == false) && (kbIsPlayerHuman(PlayerID) == false))
	{
		if (Other == VectorData)
		aiCommsSendOrderWithVector(PlayerID, Prompt, VectorData, location);
		else
		aiCommsSendOrder(PlayerID, Prompt, Other);
		Success = true;
	}		     
	if (Success == true)
	return(true);
	else
	return(false);
}

void Comms(int PlayerID = -1)
{
    int iSenderID = aiCommsGetRecordPlayerID(PlayerID);
    if ((kbIsPlayerMutualAlly(iSenderID) == true) && (kbIsPlayerResigned(iSenderID) == false) && (kbIsPlayerValid(iSenderID) == true && kbHasPlayerLost(iSenderID) == false))
    {
		int iPromptType = aiCommsGetRecordPromptType(PlayerID);
		int iUserData = aiCommsGetRecordData(PlayerID);
		vector iPos = aiCommsGetRecordPosition(PlayerID);
		if (ShowAIComms == true) aiEcho("Message received: From Player: "+iSenderID+", prompt "+iPromptType+", data "+iUserData+", vector "+iPos+".");
		
		if ((iPromptType == Tellothers) || (iPromptType == admiralTellothers))
		{
			AoModAllies = true;
			string PlayerType = "Undefined";
			if (iPromptType == Tellothers)
			PlayerType = "AoModAI";
			if (iPromptType == admiralTellothers)
			PlayerType = "AdmiralAI";
			
			aiPlanSetUserVariableInt(gSomeData, PlayersData+iSenderID, 0, 1);
		    aiEcho("Player "+iSenderID+" is an allied "+PlayerType+" player, communication is possible! :)");	
		}
		
		else if (iPromptType == AttackTarget)
		{
			if ((aiGetCaptainPlayerID(cMyID) != cMyID) || (iUserData == -1))
			return;
		    aiSetMostHatedPlayerID(iUserData);
			ChangeMHP = true;
			MHPTime = xsGetTime();
		}		
		else if (iPromptType == cAttackTC)
		{
			if ((aiGetCaptainPlayerID(cMyID) == cMyID) || (iUserData < 0))
			return;
		    aEnemyTCID = iUserData;
			aLastTCIDTime = xsGetTime();
			if (ShowAIComms == true) aiEcho("Player "+iSenderID+" is asking us to assist on tcid: "+iUserData);	
			if (aiPlanGetState(gEnemySettlementAttPlanID) > 0)
			{
				vector SettleThere = kbUnitGetPosition(aEnemyTCID);
				for (n=1; <= cNumberPlayers)
                {
					if ((n == cMyID) || (kbIsPlayerAlly(n) == true) || (kbHasPlayerLost(n) == true))
		            continue;
					if (getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, n, SettleThere, 15.0) > 0)
					{
						aiPlanSetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, aEnemyTCID);
						aiPlanSetVariableInt(gEnemySettlementAttPlanID, cAttackPlanPlayerID, 0, n);
						break;
					}	
				}
			}
		}
		
		else if (iPromptType == INeedHelp)
		{
			if ((iUserData == -1) || (findPlanByString("alliedBaseDefPlan", cPlanDefend) != -1))
			return;
			HelpSettleID = iUserData;
			xsSetRuleMinInterval("defendAlliedBase", 0);
			xsEnableRule("defendAlliedBase");
			if (ShowAIComms == true) aiEcho("Player "+iSenderID+" is asking for help at TC id "+iUserData);			 
		}
		
		else if (iPromptType == RequestTower)
		{
	        if ((iUserData == VectorData) && (equal(iPos, cInvalidVector) == false) && (kbCanAffordUnit(cUnitTypeTower, cMilitaryEscrowID) == true))
			{	
				int mainBaseID = kbBaseGetMainID(cMyID);
	            vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	            if ((gTransportMap == true) && (kbAreaGroupGetIDByPosition(iPos) != kbAreaGroupGetIDByPosition(mainBaseLocation))) // transport and can't reach?
	            return;			
				int NumBThatShoots = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAliveOrBuilding, -1, cMyID, iPos, 75.0);
				int ActiveBPlan = findPlanByString("TowerRequested", cPlanBuild);
				int allowconstructors = 15;
				if (cMyCulture == cCultureAtlantean)
				allowconstructors = 5;		
			    int numGatherers = kbUnitCount(cMyID,cBuilderType, cUnitStateAlive);
				
				if ((ActiveBPlan  == -1) && (NumBThatShoots < 2) && (kbGetAge() > cAge2) && (numGatherers > allowconstructors))
				{
					int TowerPlan=aiPlanCreate("TowerRequested", cPlanBuild);
					if (TowerPlan < 0)
					return;
				    int Building = cUnitTypeTower;
					if ((cMyCulture == cCultureAtlantean) && (kbGetTechStatus(cTechAge4Helios) == cTechStatusActive) && (kbUnitCount(cMyID, cUnitTypeTowerMirror, cUnitStateAliveOrBuilding) < 10))
					Building = cUnitTypeTowerMirror;	
					if ((aiRandInt(4) < 3) && (kbCanAffordUnit(MyFortress, cMilitaryEscrowID) == true) && (kbUnitCount(cMyID, MyFortress, cUnitStateAliveOrBuilding) < 10))
					Building = MyFortress;
					aiPlanSetVariableInt(TowerPlan, cBuildPlanBuildingTypeID, 0, Building);
					aiPlanSetVariableInt(TowerPlan, cBuildPlanMaxRetries, 0, 5);
					aiPlanSetVariableInt(TowerPlan, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(iPos));
					aiPlanSetVariableFloat(TowerPlan, cBuildPlanRandomBPValue, 0, 0.99);
					aiPlanSetVariableVector(TowerPlan, cBuildPlanInfluencePosition, 0, iPos);
					aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluencePositionDistance, 0, 25.0);
					aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluencePositionValue, 0, 1.0);
					aiPlanSetVariableInt(TowerPlan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuildingsThatShoot); 
					aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluenceUnitDistance, 0, 12);    
					aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluenceUnitValue, 0, -20.0);
					aiPlanSetDesiredPriority(TowerPlan, 80);
					aiPlanSetEscrowID(TowerPlan, cMilitaryEscrowID);
					if (cMyCulture == cCultureAtlantean)
					aiPlanAddUnitType(TowerPlan, cBuilderType, 1, 1, 1);
					else aiPlanAddUnitType(TowerPlan, cBuilderType, 1, 2, 2);
					aiPlanSetActive(TowerPlan);
					if (ShowAIComms == true) aiEcho("Player "+iSenderID+" is requesting a tower over at the following location: "+iPos);	
				}
				if ((ActiveBPlan  != -1) && (numGatherers <= allowconstructors))
				aiPlanDestroy(TowerPlan);				
			}
		}
		
		else if ((iPromptType == RequestFood) || (iPromptType == RequestWood) || (iPromptType == RequestGold))
		{
	        if ((ShouldIAgeUp() == true) && (iUserData != cEmergency))
			return;
            int AmountToSend = 0.0;
			float Percentage = 0.30;
			if (iUserData == cLowPriority)
			Percentage = 0.20;
			else if (IsTechActive(cTechAmbassadors) == true)
			Percentage = 0.40;
			
            switch(iPromptType)
			{
                case RequestFood:
                {
					AmountToSend = kbEscrowGetAmount(cRootEscrowID, cResourceFood) * Percentage;
					if ((AmountToSend > 50.0) && (kbResourceGet(cResourceFood) >= 300))
					{
						if (AmountToSend > 800)
						AmountToSend = 800;
						aiTribute(iSenderID, cResourceFood, AmountToSend);
						gLastSentTime = xsGetTime();
						if (ShowAIComms == true) aiEcho("Donated "+AmountToSend+" Food to player "+iSenderID);
					}
                    break;
				}
                case RequestWood:
                {
					AmountToSend = kbEscrowGetAmount(cRootEscrowID, cResourceWood) * Percentage;
					if ((AmountToSend > 50.0) && (kbResourceGet(cResourceWood) >= 300))
					{
						if (AmountToSend > 800)
						AmountToSend = 800;
						aiTribute(iSenderID, cResourceWood, AmountToSend);
						gLastSentTime = xsGetTime();
						if (ShowAIComms == true) aiEcho("Donated "+AmountToSend+" Wood to player "+iSenderID);
					}
                    break;
				}
                case RequestGold:
                {
					AmountToSend = kbEscrowGetAmount(cRootEscrowID, cResourceGold) * Percentage;
					if ((AmountToSend > 50.0) && (kbResourceGet(cResourceGold) >= 300))
					{
						if (AmountToSend > 800)
						AmountToSend = 800;
						aiTribute(iSenderID, cResourceGold, AmountToSend);
						gLastSentTime = xsGetTime();
						if (ShowAIComms == true) aiEcho("Donated "+AmountToSend+" Gold to player "+iSenderID);				 
					}
                    break;
				}
			}
		}
		else if ((iPromptType == ExtraFood) || (iPromptType == ExtraWood) || (iPromptType == ExtraGold))
		{
            switch(iPromptType)
			{
                case ExtraFood:
                {
					if (kbResourceGet(cResourceFood) < 400)
					MessagePlayer(iSenderID, RequestFood);
                    break;
				}
                case ExtraWood:
                {
					if (kbResourceGet(cResourceWood) < 400)
					MessagePlayer(iSenderID, RequestWood);
                    break;
				}
                case ExtraGold:
                {
					if (kbResourceGet(cResourceGold) < 400)
					MessagePlayer(iSenderID, RequestGold);
                    break;
				}
			}
		}
	}
}
//==============================================================================
// Void initRethlAge 1-4
//==============================================================================
void initRethlAge1(void)  // Am I doing this right??
{
	aiSetWonderDeathEventHandler("wonderDeathHandler");
	aiCommsSetEventHandler("Comms");
	kbLookAtAllUnitsOnMap(); // this is cheating, but it is super crucial for map detection and consistency and should have little effect on the game as it goes on.
	gSomeData = aiPlanCreate("Game Data", cPlanData);
	if (gSomeData != -1)
	{
        aiPlanSetDesiredPriority(gSomeData, 100);
		aiPlanAddUserVariableInt(gSomeData, cResourceFood, "Food Forecast ", 1);
		aiPlanAddUserVariableInt(gSomeData, cResourceGold, "Gold Forecast ", 1);
		aiPlanAddUserVariableInt(gSomeData, cResourceWood, "Wood Forecast ", 1);
	    aiPlanAddUserVariableFloat(gSomeData, 4, "F% ", 1);
	    aiPlanAddUserVariableFloat(gSomeData, 5, "G% ", 1);
	    aiPlanAddUserVariableFloat(gSomeData, 6, "W% ", 1);
		aiPlanAddUserVariableInt(gSomeData, 7, "Caravans ", 1);
		aiPlanAddUserVariableFloat(gSomeData, 8, "gGlutRatio ", 1);
		aiPlanAddUserVariableFloat(gSomeData, EcoPercentage, "EcoEscrow% ", 1);
	    aiPlanAddUserVariableFloat(gSomeData, MilPercentage, "MilEscrow% ", 1);
		aiPlanAddUserVariableFloat(gSomeData, RootPercentage, "RootEscrow% ", 1);
		
		
		//Military
	    aiPlanAddUserVariableString(gSomeData, 84, "=-------- Military --------", 1);
		aiPlanAddUserVariableInt(gSomeData, LandAttackTarget, "LandAttackTarget", 1);
		aiPlanAddUserVariableInt(gSomeData, SettlementAttackTarget, "SettleAttackTarget", 1);
		aiPlanAddUserVariableString(gSomeData, MainUnit, "Main unit ", 1);
		aiPlanAddUserVariableString(gSomeData, SecondaryUnit, "Secondary unit ", 1);
		aiPlanAddUserVariableString(gSomeData, ThirdUnit, "Tertiary unit ", 1);
		
		//Players
		aiPlanAddUserVariableString(gSomeData, PlayersData, "=-------- AoModAI Allies --------", 1);
        for (i = 1; < cNumberPlayers)
        {
           aiPlanAddUserVariableInt(gSomeData, PlayersData+i, "Player "+i, 1);
		   aiPlanSetUserVariableInt(gSomeData, PlayersData+i, 0, 0);	   
        }

	}	
	if (cMyCulture == cCultureAtlantean)
	{
		aiSetMinNumberNeedForGatheringAggressvies(3);
        aiSetMinNumberWantForGatheringAggressives(3);
	}
	
	if ((cvMapSubType == VINLANDSAGAMAP) || (cRandomMapName == "islands") || (cvRandomMapName == "river styx"))
	{
		cvOkToBuildWalls = false;
		bWallUp = false;
	}
	// Check with allies and enable donations
	MessageRel(cPlayerRelationAlly, Tellothers, 1);
	xsEnableRule("MonitorAllies");
	
	// Don't build transport ships on these maps!
	if ((cRandomMapName == "highland") || ((cRandomMapName == "Sacred Pond") || (cRandomMapName == "Sacred Pond 1.0") 
	|| (cRandomMapName == "Sacred Pond 1-0") || (cRandomMapName == "nomad") || (cRandomMapName == "Deep Jungle") 
	|| (cRandomMapName == "Mediterranean") || (cRandomMapName == "mediterranean")))
	{
		gTransportMap=false;
		if (ShowAiEcho == true) aiEcho("Not going to waste pop slots on Transport ships.");
	}
	
	if ((kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusUnobtainable) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusActive))
	TitanAvailable = true;

	if (cMyCulture == cCultureEgyptian)
	MyFortress = cUnitTypeMigdolStronghold;
	else if (cMyCulture == cCultureGreek)
	MyFortress = cUnitTypeFortress;
	else if (cMyCulture == cCultureNorse)
	{
	    MyFortress = cUnitTypeHillFort;
        cBuilderType = cUnitTypeAbstractInfantry;
	}
	else if (cMyCulture == cCultureAtlantean)
	MyFortress = cUnitTypePalace;	
	else if (cMyCulture == cCultureChinese)
	MyFortress = cUnitTypeCastle;
	if ((aiGetWorldDifficulty() == cDifficultyNightmare) || (aiGetWorldDifficulty() == cDifficultyEasy))
	gMaxTradeCarts = 16;
	defWantedCaravans = gMaxTradeCarts;
}

//==============================================================================
void initRethlAge2(void)
{
	// The Greeks are working as intended, so we're skipping that.
    
	switch(cMyCulture)
	{ 
		case cCultureGreek:
		{
			if ((cMyCiv == cCivHades) && (aiGetWorldDifficulty() != cDifficultyEasy))
			xsEnableRuleGroup("HateScriptsSpecial");
			break;
		}   
		case cCultureEgyptian:
		{   
		    xsEnableRule("buildMonuments");
		    if (cMyCiv == cCivIsis)
			xsEnableRule("getFloodOfTheNile");
		    else if (cMyCiv == cCivRa)
			xsEnableRule("getSkinOfTheRhino");	
		    else if (cMyCiv == cCivSet)
			{ 
			    xsEnableRule("getFeral");
				int Hyena = createSimpleMaintainPlan(cUnitTypeHyenaofSet, 1, false, kbBaseGetMainID(cMyID));
				aiPlanSetDesiredPriority(Hyena, 20);
			}
			if (cMyCiv != cCivSet)
			{
				int Spearman = createSimpleMaintainPlan(cUnitTypeSpearman, 1, false, kbBaseGetMainID(cMyID));
				aiPlanSetDesiredPriority(Spearman, 20);				
		        gAirScout = cUnitTypeSpearman;
                xsEnableRule("airScout1");	
            }			
			break;
		}
		case cCultureNorse:
		{	 
		    if (gUlfsarkMaintainPlanID != -1)
            aiPlanSetVariableInt(gUlfsarkMaintainPlanID, cTrainPlanNumberToMaintain, 0, 2);
		    if (cMyCiv == cCivThor)
			xsEnableRule("getPigSticker");
		    else if (cMyCiv == cCivOdin)
			xsEnableRule("getLoneWanderer");		
		    else if (cMyCiv == cCivLoki)
			xsEnableRule("getEyesInTheForest");
			break;
		}
		case cCultureAtlantean:
		{	
		    if (cMyCiv == cCivGaia)
			xsEnableRule("getChannels");
		    else if (cMyCiv == cCivOuranos)
		    xsEnableRule("buildSkyPassages");
		    else if (cMyCiv == cCivKronos)
			xsEnableRule("getFocus");
			int Turma = createSimpleMaintainPlan(cUnitTypeJavelinCavalry, 1, false, kbBaseGetMainID(cMyID));
			aiPlanSetDesiredPriority(Turma, 20);			
		    gAirScout = cUnitTypeJavelinCavalry;
            xsEnableRule("airScout1");		
			break;
		}
		case cCultureChinese:
		{	
		    xsEnableRule("buildGarden");
		    xsEnableRule("ChooseGardenResource");
		    if (cMyCiv == cCivNuwa)	
		    xsEnableRule("getAcupuncture");	
		    else if (cMyCiv == cCivShennong)
		    xsEnableRule("getWheelbarrow");
	        else if (cMyCiv == cCivFuxi)
	        xsEnableRule("rSpeedUpBuilding");		
		    aiPlanSetVariableInt(mChineseImmortal, cTrainPlanNumberToMaintain, 0, 8);
			break;
		}		
	}
	
	if ((cRandomMapName == "highland") || (cRandomMapName == "nomad"))
	{
		gWaterMap=true;
		xsEnableRule("fishing");
		if (cRandomMapName == "nomad")
		{
			xsEnableRule("NavalGoalMonitor");
			xsEnableRule("WaterDefendPlan");
		    xsEnableRule("getHeroicFleet");	
		}
		if (ShowAiEcho == true) aiEcho("Fishing enabled for Nomad and Highland map");
	}
	
	if (cRandomMapName == "valley of kings")
	xsEnableRule("BanditMigdolRemoval");
    if (aiGetGameMode() != cGameModeDeathmatch)
	xsEnableRule("CheckForCrashedPlans");	
	
    //HateScripts
	if (aiGetWorldDifficulty() != cDifficultyEasy)
    xsEnableRuleGroup("HateScripts");
	
	if ((bWallAllyMB == true) && (HasHumanAlly == true))
	xsEnableRule("WallAllyMB");
	
	if (bWallCleanup == true)
	xsEnableRuleGroup("WallCleanup");
	
    //Try to transport stranded Units.
	if (gTransportMap == true)
	xsEnableRuleGroup("BuggedTransport");

}

//==============================================================================
// RULE ActivateRethOverridesAge 1-4
//==============================================================================
rule ActivateRethOverridesAge1
minInterval 1
active
{
	int mainBaseID = kbBaseGetMainID(cMyID);
	//Delayed map check, as kbUnitCount is restricted to visible targets only, until the first second of the game has passed.
	if ((cvRandomMapName == "river styx") && (cMyCulture != cCultureEgyptian))
	{
		int Boars = NumUnitsOnAreaGroupByRel(true, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))), cUnitTypeBoar, 0);
		if (Boars < 6)
		{
			RiverSLowBoar = true;
			if (Boars < 5)
			RetardedLowBoarSpawn = true;
		}
	}
	
	if (AutoDetectMap == true)
	{
        bool Success = false;		
        int transport = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
		int numSettlements = kbUnitCount(0, cUnitTypeAbstractSettlement, cUnitStateAny);
		vector mainBasePos = kbBaseGetLocation(cMyID, mainBaseID);
		if ((mainBaseID == -1) && (kbUnitCount(cMyID, cUnitTypeBuilding, cUnitStateAlive) < 1) && (numSettlements > 0)) // check for nomad too?
		{
		    xsEnableRule("nomadSearchMode");
			cvMapSubType = NOMADMAP;
			mainBasePos = kbUnitGetPosition(findUnit(cUnitTypeUnit));
			if (kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAny) > 0)
			{
				int query=kbUnitQueryCreate("initialpos");
				configQuery(query, -1, -1, -1, cMyID);
				kbUnitQueryResetResults(query);
				int num=kbUnitQueryExecute(query);
				int base=kbBaseCreate(cMyID, "InitialIslandBase", kbUnitGetPosition(kbUnitQueryGetResult(query, 0)), 15.0);
				kbBaseSetMain(cMyID, base);
				kbBaseSetEconomy(cMyID, base, true);
				kbBaseSetMilitary(cMyID, base, true);
				kbBaseSetActive(cMyID, base, true); 
				if (ShowAiEcho == true) aiEcho("num="+num);
				for ( i=0; < num)
				{
					if (ShowAiEcho == true) aiEcho("adding unit "+i);
					kbBaseAddUnit(cMyID, base, kbUnitQueryGetResult(query, i));
				}
				gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);
				if (ShowAiEcho == true) aiEcho("Initial Base="+gVinlandsagaInitialBaseID);
				cvMapSubType = WATERNOMADMAP;
				// Move the transport toward map center to find continent quickly.
				int gTransportUnit = findUnit(cUnitTypeTransport);
				vector nearCenter = kbGetMapCenter();
				nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;    // Halfway between start and center
				nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
				aiTaskUnitMove(gTransportUnit, nearCenter);
				if (ShowAiEcho == true) aiEcho("Sending transport "+gTransportUnit+" to near map center at "+nearCenter);
				xsEnableRule("vinlandsagaFailsafe");  // In case something prevents transport from reaching, turn on the explore plan.
				
				//Enable the rule that looks for the mainland.
				xsEnableRule("findVinlandsagaBase");
				//Turn off auto dropsite building.
				if ( cMyCulture != cCultureEgyptian )
				aiSetAllowAutoDropsites(false);
				// turn off all buildings
				aiSetAllowBuildings(false);
				// turn off housebuilding rule
				xsDisableRule("buildHouse");
				
				//Turn off fishing.
				xsDisableRule("fishing");
				//Pause the age upgrades.
				aiSetPauseAllAgeUpgrades(true);
			}
			if (ShowAiEcho == true) aiEcho("Map has been detected as a Nomad Map!");
			
		}
		if (NeedTransportCheck == true) 
		{
			for (k = 1; < cNumberPlayers)
			{
				int targetSettlementID = getMainBaseUnitIDForPlayer(k);
				if (targetSettlementID == -1)
				continue;
				vector targetSettlementPos = kbUnitGetPosition(targetSettlementID);
				if ((kbAreaGroupGetIDByPosition(targetSettlementPos) != kbAreaGroupGetIDByPosition(mainBasePos))
				|| (kbUnitCount(cMyID, transport, cUnitStateAlive) > 0))
				{
					Success = true;
					break;
				}
			}
			if (Success == false) // check neutral Tcs
			{
				for (l = 0; < numSettlements)
				{
					int nTCID = findUnitByIndex(cUnitTypeAbstractSettlement, l, cUnitStateAny, -1, 0);
					vector targetNeutralPos = kbUnitGetPosition(nTCID);
					if ((nTCID != -1) && (kbAreaGroupGetIDByPosition(targetNeutralPos) != kbAreaGroupGetIDByPosition(mainBasePos)))
					{
						Success = true;
						break;
					}
				}
			}
			if (Success == true)
			{
				gTransportMap = true;
				aiSetWaterMap(gTransportMap == true);
				gWaterMap = true;
				aiEcho("Transport is needed, because a player or a TC is on a different island!");
			}
		}
	}

	// Consider any of these below, as Aggressive Animals at the start of the game.
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	int numberAggressiveResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, 85);
	int FakeAggressives = getNumUnits(cUnitTypeAnimalPrey, cUnitStateAny, -1, 0, mainBaseLocation, 85);
	if ((numberAggressiveResourceSpots > 0) || (FakeAggressives > 3))
	{
		gHuntingDogsASAP = true;
		xsEnableRule("HuntingDogsAsap");
	}	
	
	if ((gBuildWallsAtMainBase == true) && (mRusher == false) && (cvOkToBuildWalls == true))
	xsEnableRule("mainBaseAreaWallTeam1");
    if (cMyCulture == cCultureEgyptian)
    xsEnableRule("PharaohEmp");
    if ((mainBaseID >= 0) && (cvMapSubType != VINLANDSAGAMAP))
	{
	    ResourceBaseID = CreateBaseInBackLoc(mainBaseID, 30, 100, "Temp Resource Base");
	}
	xsDisableSelf();	   
}


rule ActivateRethOverridesAge2
minInterval 30
active
{
    if (kbGetAge() > cAge1)
    {
		initRethlAge2();
		//GREEK MINOR GOD SPECIFIC
		if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge2Hermes) == cTechStatusActive)
        xsEnableRuleGroup("Hermes");
	
		//CHINESE MINOR GOD SPECIFIC
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge2Change) == cTechStatusActive)
        xsEnableRuleGroup("Change");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge2Huangdi) == cTechStatusActive)
        xsEnableRuleGroup("Huangdi");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge2Sunwukong) == cTechStatusActive)
        xsEnableRuleGroup("Sunwukong");
		
		//EGYPTIAN MINOR GOD SPECIFIC
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Bast) == cTechStatusActive)
        xsEnableRuleGroup("Bast");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Ptah) == cTechStatusActive)
        xsEnableRuleGroup("Ptah");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Anubis) == cTechStatusActive)
        xsEnableRuleGroup("Anubis");
		
		//Norse MINOR GOD SPECIFIC
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge2Forseti) == cTechStatusActive)
        xsEnableRuleGroup("Forseti");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge2Freyja) == cTechStatusActive)
        xsEnableRuleGroup("Freyja");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge2Heimdall) == cTechStatusActive)
        xsEnableRuleGroup("Heimdall");
		
		//Atlantean MINOR GOD SPECIFIC
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge2Leto) == cTechStatusActive)
        xsEnableRuleGroup("Leto");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge2Prometheus) == cTechStatusActive)
        xsEnableRuleGroup("Prometheus");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge2Okeanus) == cTechStatusActive)
		{
	        xsEnableRuleGroup("Oceanus");
			int oMedic = createSimpleMaintainPlan(cUnitTypeFlyingMedic, 1, false, kbBaseGetMainID(cMyID));
	    }
		xsEnableRule("activateObeliskClearingPlan"); // this also looks for villagers, don't get confused by the name.
		if (aiGetWorldDifficulty() != cDifficultyEasy)
		xsEnableRule("LaunchAttacks"); // try to get them running more often, if pop/mil is within reason etc.
		xsDisableSelf();    	
	}
}

rule ActivateRethOverridesAge3
minInterval 30
active
{
    if (kbGetAge() > cAge2)
    {
        //GREEK MINOR GOD SPECIFIC
		if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge3Aphrodite) == cTechStatusActive)
        xsEnableRuleGroup("Aphrodite");

        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge3Apollo) == cTechStatusActive)
		xsEnableRuleGroup("Apollo");
	
        //CHINESE MINOR GOD SPECIFIC
		if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Dabogong) == cTechStatusActive)
		{
			xsEnableRuleGroup("Dabogong");
			aiPlanSetVariableInt(cMonkMaintain, cTrainPlanNumberToMaintain, 0, 5);
		}
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Hebo) == cTechStatusActive)
        xsEnableRuleGroup("Hebo");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Zhongkui) == cTechStatusActive)
        xsEnableRuleGroup("Zhongkui");
		
        //EGYPTIAN MINOR GOD SPECIFIC
		if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge3Nephthys) == cTechStatusActive)
        xsEnableRuleGroup("Nephthys");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge3Sekhmet) == cTechStatusActive)
        xsEnableRuleGroup("Sekhmet");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge3Hathor) == cTechStatusActive)
		{
	        xsEnableRuleGroup("Hathor");
			if (gTransportMap == true)
			int hRoc = createSimpleMaintainPlan(cUnitTypeRoc, 1, false, kbBaseGetMainID(cMyID));
	    }			
		
		//Norse MINOR GOD SPECIFIC
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge3Skadi) == cTechStatusActive)
        xsEnableRuleGroup("Skadi");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge3Njord) == cTechStatusActive)
        xsEnableRuleGroup("Njord");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge3Bragi) == cTechStatusActive)
        xsEnableRuleGroup("Bragi");
		
		//Atlantean MINOR GOD SPECIFIC
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge3Rheia) == cTechStatusActive)
        xsEnableRuleGroup("Rheia");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge3Theia) == cTechStatusActive)
		xsEnableRuleGroup("Theia");
		
        
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge3Hyperion) == cTechStatusActive)
        xsEnableRuleGroup("Hyperion");		
		
        xsEnableRuleGroup("ArmoryAge2");
		
		if (cMyCiv == cCivPoseidon)
		xsEnableRule("buildManyBuildings");
		
		mRusher = false;
	    if (cMyCulture == cCultureChinese)
	    {
	        if (aiGetWorldDifficulty() != cDifficultyEasy)
	        xsEnableRuleGroup("HateScriptsSpecial");
			aiPlanDestroy(eChineseHero);
		}
	    
		if (cMyCulture == cCultureEgyptian)
		{
			xsEnableRule("rebuildSiegeCamp");
			if (cMyCiv == cCivRa)
			{
				CPlanID=aiPlanCreate("Market Priest Empower", cPlanEmpower);
				if (CPlanID >= 0)
				{
					aiPlanSetEconomy(CPlanID, true);
					aiPlanAddUnitType(CPlanID, cUnitTypePriest, 0, 1, 1);
					aiPlanSetVariableInt(CPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMarket);
					aiPlanSetDesiredPriority(CPlanID, 69);							
					aiPlanSetActive(CPlanID);
				}
			}	
		}
		if (cMyCulture == cCultureNorse)
		{
        	kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeJarl, 0.8+upAV(3));
			if (cMyCiv == cCivOdin)
			kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeHuskarl, 1.0);
			else
			kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeHuskarl, 0.8+upAV(3));
			xsEnableRuleGroup("HateScriptsSpecial");
        }
		if (aiGetWorldDifficulty() != cDifficultyEasy)
		{
			int MyCata = -1;
			if (cMyCulture == cCultureGreek)
			MyCata = cUnitTypePetrobolos;
			if (cMyCulture == cCultureEgyptian)
			MyCata = cUnitTypeCatapult;
			if (cMyCulture == cCultureNorse)
			MyCata = cUnitTypeBallista;
			if (cMyCulture == cCultureAtlantean)
			MyCata = cUnitTypeOnager;
			if (cMyCulture == cCultureChinese)
			{
				if (cMyCiv == cCivShennong)
				MyCata = cUnitTypeSittingTigerShennong;
				else MyCata = cUnitTypeSittingTiger;
			}
			if (MyCata != -1)
			{
				int CataMaintain = createSimpleMaintainPlan(MyCata, 3, false, kbBaseGetMainID(cMyID));
				aiPlanSetDesiredPriority(CataMaintain, 90);
			}
			xsEnableRule("SupportUnits");		
		}
		xsDisableSelf();  
	}
}

rule ActivateRethOverridesAge4
minInterval 15
active
{
    if (kbGetAge() > cAge3)
    {
        //GREEK MINOR GOD SPECIFIC
		if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge4Artemis) == cTechStatusActive)
        xsEnableRuleGroup("Artemis");
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge4Hera) == cTechStatusActive)
        xsEnableRuleGroup("Hera");
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge4Hephaestus) == cTechStatusActive)
		xsEnableRuleGroup("Hephaestus");
	
        //CHINESE MINOR GOD SPECIFIC	
	    if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge4Aokuang) == cTechStatusActive)
        xsEnableRuleGroup("Aokuang");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge4Xiwangmu) == cTechStatusActive)
        xsEnableRuleGroup("Xiwangmu");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge4Chongli) == cTechStatusActive)
		xsEnableRuleGroup("Chongli");
		
        //Egyptian MINOR GOD SPECIFIC	
	    if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Horus) == cTechStatusActive)
        xsEnableRuleGroup("Horus");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Osiris) == cTechStatusActive)
		{
			xsEnableRuleGroup("Osiris");
			eOsiris=aiPlanCreate("Son of Osiris Empower", cPlanEmpower);
			if (eOsiris >= 0)
			{
				aiPlanSetEconomy(eOsiris, true);
				aiPlanAddUnitType(eOsiris, cUnitTypePharaohofOsiris, 1, 1, 1);
				aiPlanSetVariableInt(eOsiris, cEmpowerPlanTargetTypeID, 0, cUnitTypeAbstractSettlement);
				aiPlanSetDesiredPriority(eOsiris, 91);
				aiPlanSetBaseID(eOsiris, kbBaseGetMainID(cMyID));
				aiPlanSetVariableInt(eOsiris, cEmpowerPlanTargetID, 0, getMainBaseUnitIDForPlayer(cMyID));
				aiPlanSetActive(eOsiris);
			}
			Pempowermarket=aiPlanCreate("Pharaoh Secondary Empower", cPlanEmpower);
			if (Pempowermarket >= 0)
			{
				aiPlanSetEconomy(Pempowermarket, true);
				aiPlanAddUnitType(Pempowermarket, cUnitTypePharaohSecondary, 1, 1, 1);
				aiPlanSetVariableInt(Pempowermarket, cEmpowerPlanTargetTypeID, 0, cUnitTypeMarket); // market rarely works, but it's worth it.
				aiPlanSetDesiredPriority(Pempowermarket, 90);
				aiPlanSetActive(Pempowermarket);
			}
			if ((cMyCiv == cCivRa) && (CPlanID != -1))
			aiPlanDestroy(CPlanID);
		}
		
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Thoth) == cTechStatusActive)
		{
			xsEnableRuleGroup("Thoth");
			int PhoenixReborn = createSimpleMaintainPlan(cUnitTypePhoenixFromEgg, 5, false);
			aiPlanSetVariableBool(PhoenixReborn, cTrainPlanUseMultipleBuildings, 0, true);
			aiPlanSetVariableInt(PhoenixReborn, cTrainPlanBuildFromType, 0, cUnitTypePhoenixEgg); 
		}
		
		
		//Norse MINOR GOD SPECIFIC
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge4Tyr) == cTechStatusActive)
        xsEnableRuleGroup("Tyr");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge4Baldr) == cTechStatusActive)
        xsEnableRuleGroup("Baldr");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge4Hel) == cTechStatusActive)
        xsEnableRuleGroup("Hel");
		
		//Atlantean MINOR GOD SPECIFIC
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge4Atlas) == cTechStatusActive)
        xsEnableRuleGroup("Atlas");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge4Helios) == cTechStatusActive)
        xsEnableRuleGroup("Helios");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge4Hekate) == cTechStatusActive)
        xsEnableRuleGroup("Hekate");				
		
		
	    if (kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusObtainable)
	    xsEnableRule("repairTitanGate");
		if (aiGetWorldDifficulty() > cDifficultyModerate && (aiGetGameMode() != cGameModeDeathmatch))
		xsEnableRule("randomUpgrader");
	
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Bast) == cTechStatusActive) // Sphinx maintain, because they're just that good.
		createSimpleMaintainPlan(cUnitTypeSphinx, 2, false, kbBaseGetMainID(cMyID));
		// Unit picker
		
		if (cMyCiv == cCivZeus)
		kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeMyrmidon, 0.5+upAV(4));
		if (cMyCiv == cCivSet)
		kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeCrocodileofSet, 0.05);
		if (cMyCulture == cCultureChinese)
		{
			if (cMyCiv == cCivShennong)
			kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeFireLanceShennong, 1.0);
			else kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeFireLance, 1.0);
		}
		if (cMyCulture == cCultureNorse)
		kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAbstractArcher, 0.8+upAV(3)); // Ok to Bogsveigir now
	
		if (cMyCulture == cCultureAtlantean)
		{
			kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeTridentSoldier, 0.6+upAV(5));
			kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeArcherAtlantean, 1.0);
			kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeRoyalGuard, 0.5+upAV(4));
		}		
		//		
		xsDisableSelf();  
	}
}	  
//==============================================================================
// wonder death handler
//==============================================================================
void wonderDeathHandler(int playerID = -1)
{
	if (playerID == cMyID)
	{
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWonderDestroyed, -1);
		return;
	}
	if (playerID == aiGetMostHatedPlayerID())
	aiCommsSendStatement(playerID, cAICommPromptPlayerWonderDestroyed, -1);
}

//==============================================================================
// RULE HuntingDogsAsap
//==============================================================================
rule HuntingDogsAsap
minInterval 4
inactive
{
	
	int HuntingDogsUpgBuilding = cUnitTypeGranary;
	if (cMyCulture == cCultureChinese)
	HuntingDogsUpgBuilding = cUnitTypeStoragePit;
	if (cMyCulture == cCultureAtlantean)
	HuntingDogsUpgBuilding = cUnitTypeGuild;
	
	
	if ((WaitForDock == true) && (kbGetAge() < cAge2) || (cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeManor, cUnitStateAlive) < 1))
	return;
	
	if ((cMyCulture != cCultureNorse) && (kbUnitCount(cMyID, HuntingDogsUpgBuilding, cUnitStateAlive) < 1))
	return;
	
	if (gHuntingDogsASAP == true && aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, cTechHuntingDogs) < 0)
	createSimpleResearchPlan(cTechHuntingDogs, -1, cEconomyEscrowID, 25, true);
	xsDisableSelf();
	
}   

//==============================================================================
// RULE ALLYCatchUp
//==============================================================================
rule ALLYCatchUp
minInterval 45
inactive
Group Donations
{
	if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
	{
        xsDisableSelf();
        return;    
	}
	
	xsSetRuleMinIntervalSelf(45+aiRandInt(18));
    static int lastTargetPlayerID = -1;
    int Tcs = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    if ((Tcs < 1) || (kbGetAge() < cAge2) || (xsGetTime() < 10*60*1000))
    return;

	//First, check if we need a boost ourselves...
	int VilPop = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);
	if ((kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAliveOrBuilding) < VilPop * 0.4))
	{ 	
        bool FoodTooLow = true;
		bool GoldTooLow = true;
		bool WoodTooLow = true;
		if ((kbEscrowGetAmount(cEconomyEscrowID, cResourceFood) >= 200) || (kbEscrowGetAmount(cRootEscrowID, cResourceFood) >= 200))
		FoodTooLow = false;
	    if ((kbEscrowGetAmount(cEconomyEscrowID, cResourceGold) >= 50) || (kbEscrowGetAmount(cRootEscrowID, cResourceGold) >= 50))
		GoldTooLow = false;	
		if ((kbEscrowGetAmount(cEconomyEscrowID, cResourceWood) >= 80) || (kbEscrowGetAmount(cRootEscrowID, cResourceWood) >= 80))
		WoodTooLow = false;
	
        if (FoodTooLow == true)
		{ 
            MessageRel(cPlayerRelationAlly, RequestFood, cEmergency);
	        if (ShowAIComms == true) aiEcho("This is looking bad, requesting extra Food!");
		}
	    if (GoldTooLow == true)
		{
		    MessageRel(cPlayerRelationAlly, RequestGold, cEmergency);
	        if (ShowAIComms == true) aiEcho("This is looking bad, requesting extra Gold!");
	    }
	    if (WoodTooLow == true)
		{
		    MessageRel(cPlayerRelationAlly, RequestWood, cEmergency);
	        if (ShowAIComms == true) aiEcho("This is looking bad, requesting extra Wood!");
	    }
		if ((FoodTooLow == true) || (GoldTooLow == true) || (WoodTooLow == true))
		return;
	}	
	
	if (ShouldIAgeUp() == true)
	{   
        int Food = 800;
		int Gold = 500;	
		if (kbGetAge() == cAge3)
		{ 
			Food = 1000;
		    Gold = 1000;
		}	
        if (kbResourceGet(cResourceFood) < Food)
		{ 
            MessageRel(cPlayerRelationAlly, RequestFood);
	        if (ShowAIComms == true) aiEcho("Requesting Food for age up!");
		}
	    if (kbResourceGet(cResourceGold) < Gold)
		{
		    MessageRel(cPlayerRelationAlly, RequestGold);
	        if (ShowAIComms == true) aiEcho("Requesting Gold for age up!");
	    }
        return;
    }
    
    static int startIndex = -1; 
    startIndex = aiRandInt(cNumberPlayers);
	
    int actualPlayerID = -1;
    for (i = 0; < cNumberPlayers)
    {
        //If we're past the end of our players, go back to the start.
        int actualIndex = i + startIndex;
        if (actualIndex >= cNumberPlayers)
		actualIndex = actualIndex - cNumberPlayers;
        if ((actualIndex <= 0) || (actualIndex == cMyID))
		continue;
        if ((kbIsPlayerAlly(actualIndex) == true) && 
		(kbIsPlayerResigned(actualIndex) == false) && 
		(kbHasPlayerLost(actualIndex) == false))
        {
            actualPlayerID = actualIndex;
            if (actualIndex == lastTargetPlayerID)
            continue;
            break;
		}
	}
    if (actualPlayerID != lastTargetPlayerID)
    lastTargetPlayerID = actualPlayerID;
	
    if (actualPlayerID != -1)
    {
	    int iTcs = kbUnitCount(actualPlayerID, cUnitTypeAbstractSettlement, cUnitStateAlive);
		int iMarkets = kbUnitCount(actualPlayerID, cUnitTypeMarket, cUnitStateAlive);
	   	int houseProtoID = cUnitTypeHouse;
        if (kbGetCultureForPlayer(actualPlayerID) == cCultureAtlantean)
        houseProtoID = cUnitTypeManor;
	    int iHouses = kbUnitCount(actualPlayerID, houseProtoID, cUnitStateAlive);
		int Combined = iHouses + iTcs;
		if (Combined < 1)
		return;
		
	    float foodSupply = kbResourceGet(cResourceFood);
        float goldSupply = kbResourceGet(cResourceGold);
	    float woodSupply = kbResourceGet(cResourceWood);
		
		if ((kbGetAgeForPlayer(actualPlayerID) < cAge3) && (iTcs >= 1) && (kbGetAge() > cAge3) && (foodSupply > 1000) && (goldSupply > 800))
		{
			aiTribute(actualPlayerID, cResourceFood, 800);
			aiTribute(actualPlayerID, cResourceGold, 600);
			xsSetRuleMinIntervalSelf(55+aiRandInt(18));
			if (ShowAiEcho == true) aiEcho("Tributing 800 food and 600 gold to one of my allies!"); // Take a break too.
			return;
		}
		if ((kbGetAgeForPlayer(actualPlayerID) < cAge4) && (kbGetAgeForPlayer(actualPlayerID) == cAge3) && (iTcs >= 1) && (iMarkets >= 1) && (kbGetAge() > cAge3) && (foodSupply > 1400) && (goldSupply > 1400))
		{
			aiTribute(actualPlayerID, cResourceFood, 1000);
			aiTribute(actualPlayerID, cResourceGold, 1000);
			if (ShowAiEcho == true) aiEcho("Tributing 1000 food and 1000 gold to one of my allies!"); // Take a longer break too.
			xsSetRuleMinIntervalSelf(70+aiRandInt(18));
			return;
		}
		else
		{
			int donateFAmount = 100;
			int donateWAmount = 100;
			int donateGAmount = 100;
			int VillagerScore = kbUnitCount(actualPlayerID, cUnitTypeAbstractVillager, cUnitStateAlive);
			int AoModAlly = aiPlanGetUserVariableInt(gSomeData, PlayersData+actualPlayerID, 0);
			
			if (kbGetCultureForPlayer(actualPlayerID) == cCultureAtlantean)
			VillagerScore = VillagerScore * 3;
			
			if (aiGetWorldDifficulty() > cDifficultyHard)
			{
				if (foodSupply > 5000)
				donateFAmount = 1000;
				if (woodSupply > 3500)
				donateWAmount = 750;
				if (goldSupply > 5000)
				donateGAmount = 1000;	   
			}
			
			if (foodSupply > 2000)
			{
		        if (AoModAlly == 1)
				MessagePlayer(actualPlayerID, ExtraFood);
				else
				aiTribute(actualPlayerID, cResourceFood, donateFAmount);
			}
			if (woodSupply > 2000)
			{
		        if (AoModAlly == 1)
				MessagePlayer(actualPlayerID, ExtraWood);
				else		
				aiTribute(actualPlayerID, cResourceWood, donateWAmount);
			}
			if (goldSupply > 2000)
			{
		        if (AoModAlly == 1)
				MessagePlayer(actualPlayerID, ExtraGold);
				else		
				aiTribute(actualPlayerID, cResourceGold, donateGAmount);
			}
			
			if ((iTcs >= 1) && (AoModAlly == 0))
			{
				if ((VillagerScore <= 6) && (foodSupply > 350) && (kbGetAge() > cAge2)) // Ally appears to be dying, try to save it!
				{
					if (kbGetCultureForPlayer(actualPlayerID) == cCultureAtlantean)
					{
						aiTribute(actualPlayerID, cResourceFood, 125);
						if (woodSupply > 125)
						aiTribute(actualPlayerID, cResourceWood, 25);
					}
					else 
					aiTribute(actualPlayerID, cResourceFood, 100);
				}
			}
		}
	}
}
//==============================================================================
// RULE introChat
//==============================================================================
rule introChat
minInterval 10
active
{
	if (aiGetWorldDifficulty() != cDifficultyEasy)
	{
		for (i=1; < cNumberPlayers)
		{
			if (i == cMyID)
            continue;
			if (kbIsPlayerAlly(i) == true)
            continue;
			if (kbIsPlayerHuman(i) == true)
            aiCommsSendStatement(i, cAICommPromptIntro, -1); 
		}
	}
	xsDisableSelf();
}

//==============================================================================
// RULE myAgeTracker
//==============================================================================
rule myAgeTracker
minInterval 60
active
{
	static bool bMessage=false;
	static int messageAge=-1;
	
	//Disable this in deathmatch.
	if (aiGetGameMode() == cGameModeDeathmatch)
	{
		xsDisableSelf();
		return;
	}
	
	//Only the captain does this.
	if (aiGetCaptainPlayerID(cMyID) != cMyID)
	return;
	
	//Are we greater age than our most hated enemy?
	int myAge=kbGetAge();
	int hatedPlayerAge=kbGetAgeForPlayer(aiGetMostHatedPlayerID());
	
	//Reset the message counter if we have changed ages.
	if (bMessage == true)
	{
		if (messageAge == myAge)
		return;
		bMessage=false;
	}
	
	//Make a message??
	if ((myAge > hatedPlayerAge) && (bMessage == false))
	{
		bMessage=true;
		messageAge=myAge;
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWinningAgeRace, -1);
	}
	if ((hatedPlayerAge > myAge) && (bMessage == false))
	{
		bMessage=true;
		messageAge=myAge;
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILosingAgeRace, -1);
	}
	
	//Stop when we reach the finish line.
	if (myAge == cAge4)
	xsDisableSelf();
}

//==============================================================================
// RULE Helpme
//==============================================================================
rule Helpme
minInterval 23
inactive
{
	static bool messageSent=false;
	//Set our min interval back to 23 if it has been changed.
	if (messageSent == true)
	{
		xsSetRuleMinIntervalSelf(23);
		messageSent=false;
	}
	
	//Get our main base.
	int mainBaseID=kbBaseGetMainID(cMyID);
	if (mainBaseID < 0)
	return;
	
	//Get the time under attack.
	int secondsUnderAttack=kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
	if (secondsUnderAttack < 42)
	return;
	
	vector location=kbBaseGetLastKnownDamageLocation(cMyID, kbBaseGetMainID(cMyID));
	for (i=1; < cNumberPlayers)
	{
		if (i == cMyID)
		continue;
		if(kbIsPlayerAlly(i) == true)
		if( CanIChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptHelpHere, -1, location);
	} 
	
	//Keep the books
	messageSent=true;
	xsSetRuleMinIntervalSelf(600);  
}

//==============================================================================
// IHateSiege
//==============================================================================
rule IHateSiege
minInterval 5
inactive
group HateScripts
{
	int UnitType = cUnitTypeLogicalTypeLandMilitary;
	int Range = 30;
	int UnitToCounter = cUnitTypeAbstractSiegeWeapon;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
        if ((kbUnitIsType(unitID, cUnitTypeAbstractSiegeWeapon)) || 
		(kbUnitIsType(unitID, cUnitTypeAbstractArcher)) && (kbUnitIsType(enemyID,cUnitTypeFireLance) != true) ||
		(kbUnitIsType(unitID, cUnitTypeAbstractArcher)) && (kbUnitIsType(enemyID, cUnitTypeFireLanceShennong) != true) ||
		(kbUnitIsType(unitID, cUnitTypeAbstractInfantry)) && (kbUnitIsType(enemyID, cUnitTypeFireLance) == true) ||
		(kbUnitIsType(unitID, cUnitTypeAbstractInfantry)) && (kbUnitIsType(enemyID, cUnitTypeFireLanceShennong) == true) ||
		(kbUnitIsType(unitID, cUnitTypeAbstractInfantry)) && (kbUnitIsType(enemyID, cUnitTypeChieroballista) == true) ||
		(kbUnitIsType(unitID, cUnitTypeHeroChineseMonk)) || (kbUnitIsType(unitID, cUnitTypeHeroRagnorok)) || 
		(kbUnitIsType(unitID, cUnitTypePriest)) || (kbUnitIsType(unitID, cUnitTypeAbstractPharaoh)) || (kbUnitIsType(unitID, cUnitTypeMythUnit)))
		continue;
		int NumBSelf = getNumUnits(cUnitTypeBuilding, cUnitStateAlive, -1, cMyID, unitLoc, 36.0);
		int NumBAllies = getNumUnitsByRel(cUnitTypeBuilding, cUnitStateAlive, -1, cPlayerRelationAlly, unitLoc, 36.0, true);
		int Combined = NumBSelf + NumBAllies;		
		if ((enemyID > -1) && (Combined > 0) && (equal(unitLoc, cInvalidVector) == false))
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// tacticalHeroAttackMyth
//==============================================================================
rule tacticalHeroAttackMyth
minInterval 5
inactive
group HateScripts

{
	int UnitType = cUnitTypeHero;
	if (cMyCulture == cCultureChinese)
	UnitType = cUnitTypeHeroChineseImmortal;	
	int Range = 24;
	int UnitToCounter = cUnitTypeMythUnit;
	static bool RunOnlyOnce = false;
	
	if (cMyCulture == cCultureGreek && RunOnlyOnce == false)
	{
		static int Hero1ID = -1;
		static int Hero3ID = -1;
		static int Hero4ID = -1;
		if (cMyCiv == cCivZeus)
        {
            Hero1ID = cUnitTypeHeroGreekJason;
            Hero3ID = cUnitTypeHeroGreekHeracles;
            Hero4ID = cUnitTypeHeroGreekBellerophon;			
		}
        else if (cMyCiv == cCivPoseidon)
        {
            Hero1ID = cUnitTypeHeroGreekTheseus;
            Hero3ID = cUnitTypeHeroGreekAtalanta;
            Hero4ID = cUnitTypeHeroGreekPolyphemus;			
		}
        else if (cMyCiv == cCivHades)
        {
            Hero1ID = cUnitTypeHeroGreekAjax;
            Hero3ID = cUnitTypeHeroGreekAchilles;
            Hero4ID = cUnitTypeHeroGreekPerseus;			
		}
		if (ShowAiEcho == true) aiEcho("Heroes set");
		RunOnlyOnce = true;
	}	
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
	    if (cMyCulture != cCultureEgyptian)
		{
			if ((kbUnitIsType(enemyID, cUnitTypeFlyingUnit)) || (kbUnitIsType(enemyID, cUnitTypeEarthDragon)))
			{
				if (cMyCulture == cCultureGreek) 
				{
					if (kbUnitIsType(unitID, Hero1ID) || kbUnitIsType(unitID, Hero3ID) || kbUnitIsType(unitID, Hero4ID))    
					continue;
				}
				else if (cMyCulture == cCultureNorse) 
				{
					if (kbUnitIsType(unitID, cUnitTypeHeroNorse) || kbUnitIsType(unitID, cUnitTypeHeroRagnorok))    
					continue;
				}	
				else if (cMyCulture == cCultureAtlantean) 
				{
					if (kbUnitIsType(unitID, cUnitTypeSwordsmanHero) || kbUnitIsType(unitID, cUnitTypeTridentSoldierHero) || 
					kbUnitIsType(unitID, cUnitTypeRoyalGuardHero) || kbUnitIsType(unitID, cUnitTypeMacemanHero) || kbUnitIsType(unitID, cUnitTypeLancerHero))    
					continue;
				}
				else if (cMyCulture == cCultureChinese) 
				{
					if ((kbUnitIsType(unitID, cUnitTypeHeroChineseMonk)) || (kbUnitIsType(unitID, cUnitTypeHeroRagnorok)))   
					continue;	
				}	
			}
		}
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}
//==============================================================================
// IHateMonks
//==============================================================================
rule IHateMonks
minInterval 6
inactive
group HateScripts
{
	int UnitType = cUnitTypeAbstractArcher;
	int Range = 20;
	int UnitToCounter = cUnitTypeHeroChineseMonk;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// AntiArchSpecial
//==============================================================================
rule AntiArchSpecial
minInterval 5
inactive
group HateScriptsSpecial
{
	int UnitType = cUnitTypeCrossbowman;
	int Range = 25;
	int UnitToCounter = cUnitTypeLogicalTypeBuildingsNotWalls;	
	if (cMyCulture == cCultureChinese)
	{
		if (cMyCiv == cCivShennong)
		UnitType = cUnitTypeFireLanceShennong;
		else UnitType = cUnitTypeFireLance;
		UnitToCounter = cUnitTypeAbstractArcher;
	}
	else if (cMyCulture == cCultureNorse)
	{
	    UnitType = cUnitTypeBogsveigir;
		UnitToCounter = cUnitTypeFlyingUnit;
	}

	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if (UnitType == cUnitTypeCrossbowman)
		{
        	if ((kbUnitIsType(enemyID, cUnitTypeSettlement) == true) || (kbUnitIsType(enemyID, cUnitTypeAbstractFarm) == true) 
			|| (kbUnitIsType(enemyID, cUnitTypeHealingSpringObject) == true) || (kbUnitIsType(enemyID, cUnitTypePlentyVault) == true)
			|| (kbUnitIsType(enemyID, cUnitTypeHesperidesTree) == true))
			continue;
		}		
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// BanditMigdolRemoval // Valley of Kings special
//==============================================================================
rule BanditMigdolRemoval
minInterval 8
inactive
{
	int UnitType = cUnitTypeLogicalTypeLandMilitary;
	int Range = 30;
	int UnitToCounter = cUnitTypeBanditMigdol;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, unitLoc, 40.0);		
		if ((enemyID > -1) && (NumSelf > 10) && (equal(unitLoc, cInvalidVector) == false))
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

rule AntiInf
minInterval 5
inactive 
group HateScripts
{
	int UnitType = -1;
	int Range = 20;
	int UnitToCounter = cUnitTypeAbstractInfantry;
	
	if (cMyCulture == cCultureGreek)
	UnitType = cUnitTypeToxotes;
    else if (cMyCulture == cCultureEgyptian)
	UnitType = cUnitTypeChariotArcher;
    else if (cMyCulture == cCultureNorse)
	{
	    UnitType =  cUnitTypeThrowingAxeman;
        Range = 12;
	}
    else if (cMyCulture == cCultureAtlantean)
    UnitType =  cUnitTypeArcherAtlantean;
    else if (cMyCulture == cCultureChinese)
	UnitType =  cUnitTypeChuKoNu;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if ((kbUnitIsType(enemyID, cUnitTypeHuskarl) == true) || (kbUnitIsType(enemyID, cUnitTypeTridentSoldier) == true))
		continue;			
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

rule AntiArch
minInterval 5  
inactive
group HateScripts 
{
	int UnitType = -1;
	int Range = 18;
	int UnitToCounter = cUnitTypeAbstractArcher;
	
	if (cMyCulture == cCultureGreek)
	UnitType = cUnitTypePeltast;
    else if (cMyCulture == cCultureEgyptian)
	UnitType = cUnitTypeSlinger;
    else if (cMyCulture == cCultureAtlantean)
    UnitType = cUnitTypeJavelinCavalry;		
		
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
        if (kbUnitIsType(enemyID, cUnitTypeShip) == true)
		continue;	
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// IHateVillagers
//==============================================================================
rule IHateVillagers
minInterval 5
inactive
group HateScripts
{
	int UnitType = cUnitTypeAbstractArcher;
	int Range = 20;
	int UnitToCounter = cUnitTypeLogicalTypeIdleCivilian;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// IHateUnderworldPassages
//==============================================================================
rule IHateUnderworldPassages
minInterval 10
inactive
{
	int UnitType = cUnitTypeLogicalTypeLandMilitary;
	int Range = 20;
	int UnitToCounter = cUnitTypeTunnel;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// IHateBuildingsBeheAndScarab
//==============================================================================
rule IHateBuildingsBeheAndScarab
minInterval 12
inactive
group Sekhmet
group Rheia
{
	int UnitType = -1;
	int Range = 25;
	int UnitToCounter = cUnitTypeLogicalTypeBuildingsNotWalls;
	
	if (cMyCulture == cCultureEgyptian)
	UnitType = cUnitTypeScarab;
	else if (cMyCulture == cCultureAtlantean)
	UnitType = cUnitTypeBehemoth;

	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	
	if (UnitsFound < 1)
	{
		xsSetRuleMinIntervalSelf(65);
		return;
	}   
	xsSetRuleMinIntervalSelf(12);
	
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
        if ((kbUnitIsType(enemyID, cUnitTypeSettlement) == true) || (kbUnitIsType(enemyID, cUnitTypeAbstractFarm) == true) 
		|| (kbUnitIsType(enemyID, cUnitTypeHealingSpringObject) == true) || (kbUnitIsType(enemyID, cUnitTypePlentyVault) == true)
		|| (kbUnitIsType(enemyID, cUnitTypeHesperidesTree) == true))
		continue;		
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// IHateGates 
//==============================================================================
rule IHateGates
minInterval 5
inactive
group HateScripts
{
	int UnitType = cUnitTypeAbstractSiegeWeapon;
	int Range = 30;
	int UnitToCounter = cUnitTypeGate;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// IHateBuildingsSiege
//==============================================================================
rule IHateBuildingsSiege
minInterval 5
inactive
group HateScripts
{
	int UnitType = cUnitTypeAbstractSiegeWeapon;
	int Range = 34;
	int UnitToCounter = cUnitTypeLogicalTypeBuildingsNotWalls;
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
        if ((kbUnitIsType(enemyID, cUnitTypeSettlement) == true) || (kbUnitIsType(enemyID, cUnitTypeAbstractFarm) == true) 
		|| (kbUnitIsType(enemyID, cUnitTypeHealingSpringObject) == true) || (kbUnitIsType(enemyID, cUnitTypePlentyVault) == true)
		|| (kbUnitIsType(enemyID, cUnitTypeHesperidesTree) == true) || (kbUnitIsType(unitID, cUnitTypeChieroballista)))
		continue;
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// IHateGatesMeleeSiege // for Ram and Siphon 
//==============================================================================
rule IHateGatesMeleeSiege
minInterval 5
inactive
group HateScripts
{
	if (cMyCulture == cCultureChinese)
	{
		xsDisableSelf();
		return;
	}
	int UnitType = -1;
	int Range = 10;
	int UnitToCounter = cUnitTypeGate;
	if (cMyCulture == cCultureGreek)
	UnitType = cUnitTypeHelepolis;
	else if (cMyCulture == cCultureEgyptian)
	UnitType = cUnitTypeSiegeTower;
	else if (cMyCulture == cCultureNorse)
	UnitType = cUnitTypePortableRam;
	else if (cMyCulture == cCultureAtlantean)
    UnitType = cUnitTypeFireSiphon;	
	
	int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
	if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, unitLoc, Range);
		if(enemyID > -1)
	    aiTaskUnitWork(unitID, enemyID);
	}		
}

//==============================================================================
// MonitorAllies
//==============================================================================
rule MonitorAllies
minInterval 1  
inactive
{
    xsSetRuleMinIntervalSelf(181);
	static bool BTDT = false;
    bool Success = false;
	
    for (i=1; < cNumberPlayers)
    {
		if (i == cMyID)
		continue;
		if (kbIsPlayerMutualAlly(i) == true && kbIsPlayerResigned(i) == false && kbIsPlayerValid(i) == true && kbHasPlayerLost(i) == false)
		Success = true;
		if ((kbIsPlayerHuman(i) == true) && (kbIsPlayerMutualAlly(i) == true))
		HasHumanAlly = true;
	}
	
	if (Success == true)
	{ 
        if (BTDT == false)
		{
		    xsEnableRuleGroup("Donations");
		    xsEnableRule("defendAlliedBase");
		    xsEnableRule("Helpme");
		    IhaveAllies = true;
		    BTDT = true;
		}
	}
	else
	{
		xsDisableRuleGroup("Donations"); 
		xsDisableRule("defendAlliedBase");
		xsDisableRule("Helpme");
		IhaveAllies = false;
		AoModAllies = false;
	}
}

// KOTH COMPLEX both Land and Water
//==============================================================================
// ClaimKoth
// @param where: the position of the Vault to claim
// @param baseID: the base to get the units from. If left unspecified, the
//                funct will try to find units
//==============================================================================
void ClaimKoth(vector where=cInvalidVector, int baseToUseID=-1)
{
    if (ShowAiEcho == true) aiEcho("claimSettlement:");    
	
    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    int BoatToUse=kbUnitCount(cMyID, transportPUID, cUnitStateAlive);
	
    if (BoatToUse <= 0)
    {
		xsEnableRule("KOTHMonitor");
		if (ShowAiEcho == true) aiEcho("No ships, destroying plans!");
		DestroyTransportPlan = true;
		return;
	}
	
	int IdleTransportPlans = aiGetNumberIdlePlans(cPlanTransport);
	if (IdleTransportPlans >= 1)
	{
		DestroyHTransportPlan = true;
		xsEnableRule("KOTHMonitor");
	}
	
    vector baseLoc = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)); 
    int startAreaID = kbAreaGetIDByPosition(baseLoc);
	int ActiveTransportPlans = aiPlanGetNumber(cPlanTransport, -1, true);
    if (ActiveTransportPlans >= 1)
	{
		if (ShowAiEcho == true) aiEcho("I have 1 active transport plan, returning.");
		return;
	}
	
	if (KoTHOkNow == true)
    {
		int baseID = KOTHBASE;
		KOTHTHomeTransportPlan=createTransportPlan("GO HOME AGAIN", kbAreaGetIDByPosition(where), startAreaID, false, transportPUID, 97, baseID);
		aiPlanAddUnitType(KOTHTHomeTransportPlan, cUnitTypeHumanSoldier, 3, 6, 10);
		KoTHOkNow = false;
		if (ShowAiEcho == true) aiEcho("GO HOME TRIGGERED");
		return;													  
	}
    else 
	{
		KOTHTransportPlan=createTransportPlan("TRANSPORT TO KOTH VAULT", startAreaID, kbAreaGetIDByPosition(where), false, transportPUID, 80, baseID);
		if (kbGetTechStatus(cTechEnclosedDeck) == cTechStatusActive)
		aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 10, 20, 20);
		else aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 5, 10, 10);
		if (ShowAiEcho == true) aiEcho("GO TO VAULT TRIGGERED");
	}
}

//==============================================================================
rule getKingOfTheHillVault
minInterval 10
inactive
{
	static bool LandActive = false;
    bool LandNeedReCalculation = false;
	xsSetRuleMinIntervalSelf(22+aiRandInt(12));
	int NumEnemy = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, KOTHGlobal, 4.0, true);
	int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, KOTHGlobal, 60.0);
	
	int numAvailableUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
	if (KoTHWaterVersion == true)
	numAvailableUnits = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
	if ((numAvailableUnits < 5) || (kbGetAge() < cAge2) || (numAvailableUnits < 10) && (xsGetTime() > 14*60*1000))
	return;  
	
	if (KoTHWaterVersion == false)
	{	
		if (NumEnemy+15 > NumSelf)
		LandNeedReCalculation = true;
		
		if (LandNeedReCalculation == true)
		{	
			if (LandActive == false)
			{
				gDefendPlentyVault = createDefOrAttackPlan("KOTH VAULT DEFEND", true, 30, 12, KOTHGlobal, -1, 70, false);
				aiPlanSetNoMoreUnits(gDefendPlentyVault, false);
				aiPlanSetInitialPosition(gDefendPlentyVault, KOTHGlobal);
                aiPlanSetActive(gDefendPlentyVault);	
			    KothDefPlanActive = true;				
				LandActive = true; // active, will add more units below.
			}
			aiPlanSetNoMoreUnits(gDefendPlentyVault, false);
			aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeLogicalTypeLandMilitary, numAvailableUnits * 0.8, numAvailableUnits * 0.85, numAvailableUnits * 0.9);    // Most mil units.
			KOTHStopRefill = true;
			xsEnableRule("KOTHMonitor");
		}
	}
	
	else if (KoTHWaterVersion == true)
	{
        if ((KothDefPlanActive == false) && (NumSelf >= 1))
		{	
    	    gDefendPlentyVault = createDefOrAttackPlan("KOTH WATER VAULT DEFEND", true, 30, 12, KOTHGlobal, KOTHBASE, 70, false);	
   	        aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeHumanSoldier, 0, 0, 200);
            aiPlanSetInitialPosition(gDefendPlentyVault, KOTHGlobal);
            aiPlanSetActive(gDefendPlentyVault);
			xsEnableRule("getEnclosedDeck");
			KothDefPlanActive = true;	
		}
		
		if (NumEnemy+14 > NumSelf)
		{
			LandNeedReCalculation = false;
			ClaimKoth(KOTHGlobal);
			return;
		}	
		else if (NumSelf >  NumEnemy + 14)
		SendBackCount = SendBackCount+1;
		
		if (SendBackCount > 6)
		{
			KoTHOkNow = true;
			ClaimKoth(KOTHGlobal);
			SendBackCount = 0;		 
		}
	}	
}

//==============================================================================
rule KOTHMonitor
minInterval 2
inactive
{
    xsSetRuleMinIntervalSelf(2);
	
    if (KOTHStopRefill == true)
	{
		xsSetRuleMinIntervalSelf(5); // give some extra time to fetch units.
		aiPlanSetNoMoreUnits(gDefendPlentyVault, true);	 
		xsDisableSelf();
		KOTHStopRefill = false;
		return;
	}
	
    if ((DestroyTransportPlan == true) || (DestroyHTransportPlan == true))
	{
        int TransportToKOTHID = findPlanByString("TRANSPORT TO KOTH VAULT", cPlanTransport, -1);
		int GoHomeID = findPlanByString("GO HOME AGAIN", cPlanTransport, -1);
        if (TransportToKOTHID != -1)
		aiPlanDestroy(TransportToKOTHID);
	    if (GoHomeID != -1)
		aiPlanDestroy(GoHomeID);
		DestroyTransportPlan = false;	
		DestroyHTransportPlan = false;
	}
    xsDisableSelf();
}
// KOTH COMPLEX END
//==============================================================================

//==============================================================================
rule RemoveBadWalls
minInterval 20
group WallCleanup
inactive
{
	bool Success = false;
	int Deleted = 0;
	xsSetRuleMinIntervalSelf(12);
	int UnitsFound = kbUnitCount(cMyID, cUnitTypeGate, cUnitStateAlive);
	if (UnitsFound < 1)
	return;
	
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(cUnitTypeGate, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		if (Deleted > 10) // should not happen in a normal game...
		break;
	
		for (k=0; < 4)
		{
			int unitTypeID=-1;
			if (k==0)
			unitTypeID=cUnitTypeWallConnector;
			else if (k==1)
			unitTypeID=cUnitTypeWallMedium;
			else if (k==2)
			unitTypeID=cUnitTypeWallShort;
			else if (k==3)
			unitTypeID=cUnitTypeWallLong;
			int BadWalls = getNumUnits(unitTypeID, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc, 4);
			for (j=0; < BadWalls)
			{
				int WallPiece = findUnitByIndex(unitTypeID, j, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc);
				if (WallPiece != -1)
				{
				    aiTaskUnitDelete(WallPiece);
					Deleted = Deleted +1;
				    Success = true;
				}
			}		
		}
	}
    if (Success == true)
    xsSetRuleMinIntervalSelf(2);	
}

//==============================================================================
rule RemoveTooCloseDocks
minInterval 6
inactive
{
	int unitTypeID = cUnitTypeDock;
	int UnitsFound = kbUnitCount(cMyID, unitTypeID, cUnitStateAlive);
	if (UnitsFound < 1)
	return;
    bool Success = false;
	for (i=0; < UnitsFound)
	{
		int unitID = findUnitByIndex(unitTypeID, i, cUnitStateAlive);
		vector unitLoc = kbUnitGetPosition(unitID);
		int BadDocks = kbUnitCount(cMyID, unitTypeID, cUnitStateBuilding);
		for (j=0; < BadDocks)
		{		
			int BadDock = findUnitByIndex(unitTypeID, j, cUnitStateBuilding, -1, cMyID, unitLoc, 15);
			if (BadDock != unitID)
			{
				aiTaskUnitDelete(BadDock);
				Success = true;
			}
		}		
		
	}
	if (Success == true)
	{
	    xsSetRuleMinInterval("dockMonitor", 8);
		xsEnableRule("dockMonitor");
	}
}
//==============================================================================
rule TransportBuggedUnits  
minInterval 14
group BuggedTransport
inactive
{
	static int TransportAttPlanID = -1;
	int IdleMil = aiNumberUnassignedUnits(cUnitTypeLogicalTypeLandMilitary);
	static int attackPlanStartTime = -1;
	static int targetSettlementID = -1;
	int AttackPlayer = aiGetMostHatedPlayerID();
	xsSetRuleMinIntervalSelf(30);
	static vector attPlanPosition = cInvalidVector;
	bool Filled = false;
	
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true);  // Attack plans, any state, active only
	if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (ShowAiEcho == true) aiEcho("attackPlanID: "+attackPlanID);
            if (attackPlanID == -1)
			continue;
			if (attackPlanID == TransportAttPlanID)	
			{
				int planState = aiPlanGetState(TransportAttPlanID);
				int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
				attPlanPosition = aiPlanGetLocation(TransportAttPlanID);
				int numMilUnitsNearAttPlan = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, attPlanPosition);
				int numInPlan = aiPlanGetNumberUnits(TransportAttPlanID, cUnitTypeLogicalTypeLandMilitary);
				int numTransport = kbUnitCount(cMyID, transportPUID, cUnitStateAlive);
				if (numMilUnitsNearAttPlan >= 20)
				numMilUnitsNearAttPlan = 20;
				if (numInPlan > 1)
				Filled = true;
				
				
				if (Filled == false)
				{
					aiPlanSetInitialPosition(TransportAttPlanID, attPlanPosition);
					aiPlanAddUnitType(TransportAttPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, numMilUnitsNearAttPlan);
					aiPlanSetVariableFloat(TransportAttPlanID, cAttackPlanGatherDistance, 0, 500.0);
				}		   
				if (ShowAiEcho == true) aiEcho("planState: "+planState);		   
				
				if ((numInPlan < 1) || (xsGetTime() > attackPlanStartTime + 30*60*1000) || (planState == cPlanStateNone) && (xsGetTime() > attackPlanStartTime + 5*60*1000) ||
				(planState == cPlanStateGather) && (xsGetTime() > attackPlanStartTime + 5*60*1000) 
				|| ((aiPlanGetState(attackPlanID) == cPlanStateTransport) && (numTransport < 1) (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)))
				{
					aiPlanDestroy(TransportAttPlanID);
					xsSetRuleMinIntervalSelf(5);
				}
				return;
			}
		}
	}
    if (IdleMil < 3)
	return;	

    TransportAttPlanID = aiPlanCreate("Transport bugged units", cPlanAttack);
    if (TransportAttPlanID < 0)
    return; 
	
    if (ShowAiEcho == true) aiEcho(""+TransportAttPlanID+"");
	
    TransportAttPlanID = TransportAttPlanID;
	targetSettlementID = getMainBaseUnitIDForPlayer(AttackPlayer);
	if (targetSettlementID == -1)
	targetSettlementID = findUnit(cUnitTypeUnit, cUnitStateAlive, -1, AttackPlayer); 
	vector targetSettlementPos = kbUnitGetPosition(targetSettlementID); // uses main TC
    vector RandUnit = kbUnitGetPosition(findUnit(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, AttackPlayer));
	vector RandBuilding = kbUnitGetPosition(findUnit(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, AttackPlayer));
    vector RandVillager = kbUnitGetPosition(findUnit(cUnitTypeAbstractVillager, cUnitStateAlive, -1, AttackPlayer));
	attPlanPosition = aiPlanGetLocation(TransportAttPlanID);
	aiPlanSetNumberVariableValues(TransportAttPlanID, cAttackPlanTargetAreaGroups, 5, true);   
	aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(attPlanPosition));
	aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(targetSettlementPos));
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 2, kbAreaGroupGetIDByPosition(RandUnit));
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 3, kbAreaGroupGetIDByPosition(RandBuilding));
	aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 4, kbAreaGroupGetIDByPosition(RandVillager));	
	aiPlanAddUnitType(TransportAttPlanID, cUnitTypeHumanSoldier, 0, 0, 1);
	
	
	aiPlanSetInitialPosition(TransportAttPlanID, attPlanPosition);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
    aiPlanSetUnitStance(TransportAttPlanID, cUnitStanceDefensive);
    aiPlanSetDesiredPriority(TransportAttPlanID, 1);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanPlayerID, 0, AttackPlayer);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
    aiPlanSetNumberVariableValues(TransportAttPlanID, cAttackPlanTargetTypeID, 4, true); 
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeUnit);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeBuilding);
	aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeAbstractTradeUnit);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanRefreshFrequency, 0, 12);
	aiPlanSetVariableFloat(TransportAttPlanID, cAttackPlanGatherDistance, 0, 50.0);
	
    aiPlanSetActive(TransportAttPlanID);
    attackPlanStartTime = xsGetTime();
	
    xsSetRuleMinIntervalSelf(5);
}

//==============================================================================
rule TransportShipMonitor
minInterval 30
group BuggedTransport
inactive
{
	int TransAlive = kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive);
	int Docks = kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAlive);
	int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
	if ((TransAlive > 0) || (Docks < 1))
	return;
	
	int currentPop = kbGetPop();
	int currentPopCap = kbGetPopCap();
	int TransInProgress = kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateBuilding);
	if ((currentPop >= currentPopCap - 3) && (currentPopCap > 100) && (TransInProgress > 0))
	{
		int PlanToUse = findPlanByString("landAttackPlan", cPlanAttack);
		int KillCounter = 0;
		if (PlanToUse == -1)
		PlanToUse = findPlanByString("enemy settlement attack plan", cPlanAttack);
		if ((PlanToUse != -1) && (aiPlanGetState(PlanToUse) == cPlanStateTransport))
		{
			for (i = 0; < kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive))
			{
				int UnitToKill = findUnitByIndex(cUnitTypeHumanSoldier, i, cUnitStateAlive, -1, cMyID);
				if ((aiPlanGetState(kbUnitGetPlanID(UnitToKill)) <=0) || (UnitToKill == -1))
				continue ;
				aiTaskUnitDelete(UnitToKill);
				KillCounter = KillCounter + 1;
				if (KillCounter >= 2)
				break;
			}
		}
			
	}
	else if ((currentPop >= currentPopCap - 3) && (currentPopCap > 100) && (TransInProgress < 1) && (kbResourceGet(cResourceWood) > 250))
	aiTaskUnitTrain(findUnit(cUnitTypeDock), transportPUID);		
}

//==============================================================================
rule StuckNorseTransform  
minInterval 3
inactive
{
	if (kbUnitIsType(StuckTransformID, cUnitTypeUlfsark))
	{
		vector currentPosition = kbUnitGetPosition(StuckTransformID);	  
		aiUnitCreateCheat(cMyID, cUnitTypeUlfsark, currentPosition, "Replacing Stuck Ulfsark", 1);
		aiTaskUnitDelete(StuckTransformID);
	}
	StuckTransformID = 0;	  
	xsDisableSelf();	  
}

//==============================================================================
rule FishBoatMonitor  
minInterval 6
inactive
{
	if (gFishPlanID != -1)
	{	
		int Ship = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
		int IdleFishingShips = getNumUnits(Ship, cUnitStateAlive, cActionIdle, cMyID);
		int FishingShips = getNumUnits(Ship, cUnitStateAlive, -1, cMyID);
		int Training = aiPlanGetVariableInt(gFishPlanID, cFishPlanNumberInTraining, 0);
		
		if ((kbResourceGet(cResourceWood) < 125) || (IdleFishingShips >= 1) 
		|| (gNavalAttackGoalID != -1) && (kbGetAge() >= cAge2) && (aiGetWorldDifficulty() > cDifficultyModerate) && (kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive) < 2) 
		|| (kbGetAge() == cAge1) && (FishingShips >= 4) && (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding) < 1) && (cMyCulture != cCultureEgyptian))
		{
			aiPlanSetVariableBool(gFishPlanID, cFishPlanAutoTrainBoats, 0, false);
		}
		else aiPlanSetVariableBool(gFishPlanID, cFishPlanAutoTrainBoats, 0, true);
	}
	
	if (gMaintainWaterXPortPlanID != -1)
	{
	    if ((gNavalAttackGoalID != -1) && (kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive) < 1))
	    aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 0);
	    else
	    aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 2);		
	}
}

//==============================================================================
rule LaunchAttacks
minInterval 12
inactive
{
	int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
	vector defPlanDefPoint = aiPlanGetVariableVector(gDefendPlanID, cDefendPlanDefendPoint, 0);
	int numEnemyMilUnitsNearDefPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 70.0, true);
	int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 90.0, true);
	int LandAActive = findPlanByString("landAttackPlan", cPlanAttack);
	int SettlementAActive = findPlanByString("enemy settlement attack plan", cPlanAttack);
	
	if (ShouldIAgeUp() == true)
	xsSetRuleMinIntervalSelf(120);
    else
	xsSetRuleMinIntervalSelf(12);	
	
	
	if ((numEnemyTitansNearMBInR85 > 0) || (numEnemyMilUnitsNearMBInR80 > 10) || (numEnemyMilUnitsNearDefPlan > 10) || (kbGetAge() == cAge2) && (LandAActive > 0)
	|| (LandAActive > 0) && (SettlementAActive > 0) || (kbGetAge() == cAge2) && (xsGetTime() >= 15*60*1000))
	return;
	
	if (ReadyToAttack() == true)
	{
		if ((LandAActive < 0) && (SettlementAActive != -1) || (kbGetAge() == cAge2))
		{
			xsSetRuleMinInterval("createLandAttack", 2);
			xsEnableRule("createLandAttack");
		}
		else if ((SettlementAActive < 0) && (LandAActive != -1))	
		{  
			xsSetRuleMinInterval("attackEnemySettlement", 2);
			xsEnableRule("attackEnemySettlement");	
		}
		else
		{
			if (aiRandInt(3) == 0)
			{
				xsSetRuleMinInterval("attackEnemySettlement", 2);
				xsEnableRule("attackEnemySettlement");	
			}
			else
			{
				xsSetRuleMinInterval("createLandAttack", 2);
				xsEnableRule("createLandAttack");	
			}
		}
	}
}

//==============================================================================
rule CheckForCrashedPlans
minInterval 65
inactive
{
	if ((kbResourceGet(cResourceFood) < 200) || (kbResourceGet(cResourceWood) < 200) || (kbResourceGet(cResourceGold) < 200))
    return;
	
    xsSetRuleMinIntervalSelf(65);
	bool SwitchType = false;
	int PlanType = cPlanResearch;
    bool Progression = false;
	
	for (j = 0; < 2)
	{
		int PlanID = -1;
		int NumVar = -1;
		int PlanToUse = -1;
		int SpecialNum = -1;
		int TimeActive = -1;
		bool PlanCrashed = false;
		if (SwitchType == true)
		PlanType = cPlanProgression;
		SwitchType = true;
		int ActivePlans = aiPlanGetNumber(PlanType, -1, true);
		if ((ActivePlans > 0) && (PlanCrashed == false))
		{
			for (i = 0; < ActivePlans)
			{
				PlanID = aiPlanGetIDByIndex(PlanType, -1, true, i);
				if ((PlanID == -1) || (kbGetTechStatus(PlanID) >= cTechStatusResearching))
				continue;	
				NumVar = aiPlanGetNumberUserVariableValues(PlanID, 0);
				if (NumVar == 3) 
				{
					SpecialNum = aiPlanGetUserVariableInt(PlanID, 0, 0);
					TimeActive = aiPlanGetUserVariableInt(PlanID, 0, 1);
					if ((SpecialNum == 19) && (xsGetTime() > TimeActive + 6*60*1000))
					{
						PlanCrashed = true;
						PlanToUse = PlanID;
						if (PlanType == cPlanProgression)
						Progression = true;
					}
					
					if ((PlanCrashed == true) && (PlanToUse != -1)) 
					{
						int Tech = aiPlanGetUserVariableInt(PlanToUse, 0, 2);
						int BuildingID = aiPlanGetVariableInt(PlanToUse, cResearchPlanBuildingTypeID, 0);
						int EscrowID = aiPlanGetEscrowID(PlanToUse);
						int Prio = aiPlanGetActualPriority(PlanToUse);
						int IdleTime = (xsGetTime() - TimeActive) / 1000;
						if (ShowAiEcho == true) aiEcho("Plan to research (" + kbGetTechName(Tech) + ") appears to have crashed, idle time: "+IdleTime +" seconds.. restarting the plan!");
						aiPlanDestroy(PlanToUse);
						if (Tech != -1)
						createSimpleResearchPlan(Tech, BuildingID, EscrowID, Prio, Progression, true);
						xsSetRuleMinIntervalSelf(10);
						return;
					}						
				}
			}
		}
	}
}

//==============================================================================
//Testing ground
rule TEST  
minInterval 1
inactive
{
}