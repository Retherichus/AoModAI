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
//Below, you'll find the Plan handler. 
//you don't really want to touch this.. and if you do, you'll break stuff.
//==============================================================================
mutable bool persWantForwardBase() {}
extern int gForwardBaseID=-1;
extern int fCitadelPlanID = -1;
extern int gShiftingSandPlanID= -1;
mutable void retreatHandler(int planID=-1) {}
mutable void relicHandler(int relicID=-1) {}
mutable void wonderDeathHandler(int playerID=-1) { }
extern bool ConfirmFish = false;          // Don't change this, It's for extra safety when fishing, and it'll enable itself if fish is found.
extern bool gHuntingDogsASAP = false;     // Will automatically be called upon if there is huntable nearby the MB.
extern int gGardenBuildLimit = 0;
extern int HateChoice = -1;
extern int gInitialWoodBaseID = -1;
extern int gLandExplorePlanID2=-1;
extern int gLandScoutSpecialUlfsark = -1;
extern bool IsRunTradeUnits1 = false;
extern bool IsRunTradeUnits2 = false;
extern bool IsRunHuntingDogs = false;
extern bool IsRunWallSize = false;
extern bool BoomV2 = true;
extern int TotalTreesNearMB = -1;
extern int numTeesNearMainBase = -1;
extern int gDefendPlentyVault = -1;



//////////////// aiEchoDEBUG ////////////////

extern bool ShowAiEcho = false; // All aiEcho, see specific below to override.
extern bool ShowAiEcoEcho = false;
extern bool ShowAiGenEcho = false;
extern bool ShowAiMilEcho = false;
extern bool ShowAiDefEcho = false;
extern bool ShowAiTestEcho = false;

//////////////// END OF aiEchoDEBUG ////////////////

//==============================================================================
//PART 2 Bools & Stuff you can change!
//Below, you'll find a few things I've set up,
//you can turn these on/off as you please, by setting the final value to "true" (on) or "false" (off).
//There's also a small description on all of them, to make it a little easier to understand what happens when you set it to true.
//==============================================================================
extern bool mCanIDefendAllies = true;     // Allows the AI to defend his allies.
extern bool gWallsInDM = true;            // This allows the Ai to build walls in the gametype ''Deathmatch''.
extern bool gAgeFaster = false;            // This will lower the amount of military units the AI will train in Classical Age, this will allow the Ai to progress faster to Heroic Age, config below.
extern bool gSuperboom = true;            // The Ai will set goals to harvest X Food, X Gold and X Wood at a set timer, see below for conf.
extern bool RethEcoGoals = true;          // Similar to gSuperboom, this will take care of the resources the Ai will try to maintain in Age 2-4, see more below.
extern bool RethFishEco = true;          // Changes the default fishing plan, by forcing early fishing(On fishing maps only). This causes the villagers to go heavy on Wood for the first 2 minutes of the game.
extern bool bWallUp = true;              // This ensures that the Ai will build walls(almost always), regardless of personality.
extern bool Age3Armory = false;           // Prevents the Ai from researching armory upgrades before reaching Heroic Age.
extern bool OneMBDefPlanOnly = true;      // Only allow one active "idle defense plan for Mainbase (6 units, 12 if set to false)"

extern bool ResInflate = true;            // Sets the food multiplier to 1.0 once above 5k food.
extern bool gHuntEarly = true;            // This will make villagers hunt aggressive animals way earlier, though this can be a little bit dangerous! (Damn you Elephants!) 
extern bool CanIChat = true;              // This will allow the Ai to send chat messages, such as asking for help if it's in danger.
extern bool gEarlyMonuments = false;       // This allows the Ai to build Monuments in Archaic Age. Egyptian only.
extern bool bHouseBunkering = true;       // Makes the Ai bunker up towers with Houses.

//For gAgefaster when true.
extern int eMaxMilPop = 50;               // Max military pop cap during Classical Age, the lower it is, the faster it'll advance, but leaving it defenseless can be just as bad!


// If gSuperboom is set to true, the numbers below are what the Ai will attempt to gather in Archaic Age or untill X minutes have passed.
// This can be a bit unstable if you leave it on for more than 4+ min, but it's usually very rewarding. 
// Note: This is always delayed by 2 minutes into the game. this is due to EarlyEcon rules, which release villagers for other tasks at the 2 minute marker.

extern int eBoomFood = 600;              // Food
extern int eBoomGold = 150;              // Gold
extern int eBoomWood = 200;              // Wood, duh.


//Egyptians have their own, because they don't like wood as much.

extern int egBoomGold = 250;              // Gold
extern int egBoomWood = 0;              // Wood


// For RethFishEco, this affects Fishing Maps ONLY, if you have it enabled.
// If the Ai fails to find any valid fishing spot for any reason, it'll scrap this fishing plan and return to normal resource distribution.

extern int eFBoomFood = 50;              // Food
extern int eFBoomGold = 0;              // Gold
extern int eFBoomWood = 50;             // Wood, The Ai will automatically boost it, if it's too low.


//Timer for gSuperboom & fishing
extern int eBoomTimer = 6;                // Minutes this plan will remain active. It'll disable itself after X minutes set.(minus delay) 
extern int eFishTimer = 75;                // Seconds the Ai will go heavy on Wood, this supports the Ai in building early fishing ships.







// For RethEcoGoals, AoModAi do normally calculate the resources it needs, though.. we want it to keep some extra resources at all times, 
// so, let's make it a little bit more ''static'' by setting resource goals a little closer to what Admiral Ai use.
// Do note that anything you put in here will get added on top of the default goals, some values may appear to be very low but it really isn't.
//==============================================================================
//Greek
//==============================================================================
//Age 2 (Classical Age)
extern int RethLGFAge2 = 800;             // Food
extern int RethLGGAge2 = 550;              // Gold
extern int RethLGWAge2 = 400;              // Wood

//Age 3 (Heroic Age)

extern int RethLGFAge3 = 1300;              // Food
extern int RethLGGAge3 = 1700;              // Gold
extern int RethLGWAge3 = 600;              // Wood

//Age 4 (Mythic Age)

extern int RethLGFAge4 = 4300;              // Food
extern int RethLGGAge4 = 3600;              // Gold
extern int RethLGWAge4 = 2300;              // Wood


//==============================================================================
//Egyptian
//==============================================================================

//Age 2 (Classical Age)
extern int RethLEFAge2 = 800;              // Food
extern int RethLEGAge2 = 700;              // Gold
extern int RethLEWAge2 = 100;              // Wood

//Age 3 (Heroic Age)

extern int RethLEFAge3 = 1300;              // Food
extern int RethLEGAge3 = 1700;              // Gold
extern int RethLEWAge3 = 450;              // Wood

//Age 4 (Mythic Age)

extern int RethLEFAge4 = 4300;              // Food
extern int RethLEGAge4 = 3600;              // Gold
extern int RethLEWAge4 = 1200;              // Wood

//==============================================================================
//Norse
//==============================================================================

//Age 2 (Classical Age)
extern int RethLNFAge2 = 800;             // Food
extern int RethLNGAge2 = 600;              // Gold
extern int RethLNWAge2 = 400;              // Wood

//Age 3 (Heroic Age)

extern int RethLNFAge3 = 1200;              // Food
extern int RethLNGAge3 = 1700;              // Gold
extern int RethLNWAge3 = 750;              // Wood

//Age 4 (Mythic Age)

extern int RethLNFAge4 = 4300;              // Food
extern int RethLNGAge4 = 3600;              // Gold
extern int RethLNWAge4 = 2300;              // Wood

//==============================================================================
//Atlantean
//==============================================================================

//Age 2 (Classical Age)
extern int RethLAFAge2 = 800;              // Food
extern int RethLAGAge2 = 600;              // Gold
extern int RethLAWAge2 = 400;              // Wood

//Age 3 (Heroic Age)

extern int RethLAFAge3 = 1700;              // Food
extern int RethLAGAge3 = 1400;              // Gold
extern int RethLAWAge3 = 800;              // Wood

//Age 4 (Mythic Age)

extern int RethLAFAge4 = 4300;              // Food
extern int RethLAGAge4 = 3600;              // Gold
extern int RethLAWAge4 = 2300;              // Wood


//==============================================================================
//Chinese
//==============================================================================

//Age 2 (Classical Age)
extern int RethLCFAge2 = 800;              // Food
extern int RethLCGAge2 = 550;              // Gold
extern int RethLCWAge2 = 400;              // Wood

//Age 3 (Heroic Age)

extern int RethLCFAge3 = 1300;              // Food
extern int RethLCGAge3 = 1700;              // Gold
extern int RethLCWAge3 = 450;              // Wood

//Age 4 (Mythic Age)

extern int RethLCFAge4 = 4300;              // Food
extern int RethLCGAge4 = 3600;              // Gold
extern int RethLCWAge4 = 2300;              // Wood

//==============================================================================
//PART 3 Overrides & Rules
//From here and below, you'll find my custom rules, 
//as well with some ''Handlers/Overrides'' if we could call it that.
//==============================================================================



//==============================================================================
// Void initRethlAge 1-4
//==============================================================================
void initRethlAge1(void)  // Am I doing this right??
{
	
	aiSetRelicEventHandler("relicHandler");
	aiSetRetreatEventHandler("retreatHandler");
	aiSetWonderDeathEventHandler("wonderDeathHandler");
	// kbLookAtAllUnitsOnMap();   // Semi cheating!.. Disabled due to unstable results.
	
	/*
	if (aiIsMultiplayer() == false)
	if (ShowAiEcho == true || ShowAiGenEcho == true) aiEcho("We're in a singleplayer/offline game, nothing can stop us here!");                 // Just to confirm game mode.
	
	if (aiIsMultiplayer() == true)
	if (ShowAiEcho == true || ShowAiGenEcho == true) aiEcho("We're in a multiplayer game, I will make sure not to use any De-sync sensitive Godpowers.");  // ^ Ditto, heh.
	*/
	
	if (cMyCulture == cCultureEgyptian && gEarlyMonuments == true)
    xsEnableRule("buildMonuments");
	    
	   
	   if (gHuntEarly == true && cRandomMapName != "Deep Jungle" && cRandomMapName != "erebus")
		{
		if (cMyCulture == cCultureGreek)
		aiSetMinNumberNeedForGatheringAggressvies(4);      // The number inside of ( ) represents the amount of villagers/units needed.
		if (cMyCulture == cCultureAtlantean)
		aiSetMinNumberNeedForGatheringAggressvies(1);
	    if (cMyCulture == cCultureEgyptian)
		aiSetMinNumberNeedForGatheringAggressvies(4);
		if (cMyCulture == cCultureNorse)
		aiSetMinNumberNeedForGatheringAggressvies(4);
		if (cMyCulture == cCultureChinese)
		aiSetMinNumberNeedForGatheringAggressvies(4);
		
        }
      
	   // Don't build transport ships on these maps!
	   if ((cRandomMapName == "highlands") || ((cRandomMapName == "Sacred Pond") || (cRandomMapName == "Sacred Pond 1.0") || (cRandomMapName == "Sacred Pond 1-0") || (cRandomMapName == "nomad") || (cRandomMapName == "Deep Jungle") || (cRandomMapName == "Mediterranean") || (cRandomMapName == "mediterranean")))
	   {
	   gTransportMap=false;
	   if (ShowAiEcho == true) aiEcho("Not going to waste pop slots on Transport ships.");
	   }
}

//==============================================================================
void initRethlAge2(void)
{
	// The Greeks are working as intended, so we're skipping that.
    
	if (cMyCiv == cCivHades)
    {   	
	xsEnableRuleGroup("HateScriptsH");
    }   

   if (cMyCiv == cCivIsis)
    {   	
	xsEnableRule("getFloodOfTheNile");
    }
    if (cMyCiv == cCivRa)		
	{	 
	xsEnableRule("getSkinOfTheRhino");
    }    
	if (cMyCiv == cCivSet)
    {	
	xsEnableRule("getFeral");
    }
	if (cMyCiv == cCivThor)
    {	 
	xsEnableRule("getPigSticker");
    }
	if (cMyCiv == cCivOdin)		
	{	
	xsEnableRule("getLoneWanderer");
    }
	if (cMyCiv == cCivLoki)
    {
	xsEnableRule("getEyesInTheForest");
    }
	if (cMyCiv == cCivGaia)
    {	
	xsEnableRule("getChannels");
    }
	if (cMyCiv == cCivKronos)
    {	
	xsEnableRule("getFocus");
    }
	if (cMyCiv == cCivNuwa)
    {	
	xsEnableRule("getAcupuncture");
	xsEnableRule("getEarthenWall");
	xsEnableRule("buildGarden");
	xsEnableRule("ChooseGardenResource");	
    }	
	if (cMyCiv == cCivFuxi)
    {	
	xsEnableRule("getDomestication");
	xsEnableRule("getEarthenWall");
	xsEnableRule("buildGarden");
	xsEnableRule("ChooseGardenResource");	
    }	
	if (cMyCiv == cCivShennong)
    {	
	xsEnableRule("getWheelbarrow");
	xsEnableRule("getEarthenWall");
	xsEnableRule("buildGarden");
	xsEnableRule("ChooseGardenResource");
    }		
	   if ((cRandomMapName == "highland") || (cRandomMapName == "nomad"))
	{
	gWaterMap=true;
	ConfirmFish=true;
	xsEnableRule("fishing");
	if (ShowAiEcho == true) aiEcho("Fishing enabled for Nomad and Highland map");
	}

	//  Enable Dock defense. 
    xsEnableRule("DockDefenseMonitor");
    //HateScripts
    xsEnableRuleGroup("HateScripts");
	
	// Check with allies and enable donations
    xsEnableRule("MonitorAllies");


}	

//==============================================================================
// RULE ActivateRethOverridesAge 1-4
//==============================================================================
rule ActivateRethOverridesAge1
   minInterval 1
   active
   runImmediately
{
        initRethlAge1();
		if (gHuntingDogsASAP == true)
		xsEnableRule("HuntingDogsAsap");
		
		if (aiGetWorldDifficulty() > cDifficultyHard)
		xsEnableRuleGroup("MassDonations");
		
		
		/*
		// Force Dock down.
		if (gWaterMap == true && RethFishEco == true)
   {
      int areaID=kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
      int buildDock=aiPlanCreate("BuildDock", cPlanBuild);
      if (buildDock >= 0)
      {
         aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
         aiPlanSetDesiredPriority(buildDock, 30);
         aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
         aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, kbAreaGetCenter(areaID));
         aiPlanAddUnitType(buildDock, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
         aiPlanSetEscrowID(buildDock, cEconomyEscrowID);
         aiPlanSetActive(buildDock);
      }
   }
	*/	
		
		xsDisableSelf();
           
    }
	
rule ActivateRethOverridesAge2
   minInterval 30
   active
{
    if (kbGetAge() > cAge1)
    {
		initRethlAge2();
		
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
        xsEnableRuleGroup("Oceanus");
		
		if (cMyCulture == cCultureNorse)
		{
		aiPlanDestroy(gLandExplorePlanID2);
		xsDisableRule("startLandScouting");
		}
		
		xsDisableSelf();
		
           
    }
}

rule ActivateRethOverridesAge3
   minInterval 30
   active
{
    if (kbGetAge() > cAge2)
    {
        //CHINESE MINOR GOD SPECIFIC
		if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Dabogong) == cTechStatusActive)
        xsEnableRuleGroup("Dabogong");
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
        xsEnableRuleGroup("Hathor");		
		
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
		
		if (cMyCiv != cCivThor && Age3Armory == true)
        xsEnableRuleGroup("ArmoryAge2");
        if (cMyCiv == cCivThor && Age3Armory == true)
        xsEnableRuleGroup("ArmoryThor");
		
		if (cMyCiv == cCivPoseidon)
		xsEnableRule("buildManyBuildings");
		
		xsDisableSelf();
           
    }
}

rule ActivateRethOverridesAge4
   minInterval 30
   active
{
    if (kbGetAge() > cAge3)
    {
	
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
        xsEnableRuleGroup("Osiris");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Thoth) == cTechStatusActive)
        xsEnableRuleGroup("Thoth");		
		
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
		
		
		
		if (cMyCulture == cCultureNorse)
		xsEnableRule("getMediumArchers");	
    
	    if (kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusObtainable)
	    xsEnableRule("repairTitanGate");
		if (aiGetWorldDifficulty() > cDifficultyModerate)
		xsEnableRule("randomUpgrader");
		
		xsDisableSelf();
           
    }
}	


//==============================================================================
// rule DockDefenseMonitor
//==============================================================================
rule DockDefenseMonitor
   minInterval 45
   inactive
{  

   	   if (gWaterMap == false)
	   {
	   xsDisableSelf();
	   return;
	   }
   
   // Add some defense for the dock
   
         if (gWaterMap == true && kbGetAge() > cAge1 && cRandomMapName != "sudden death" && cRandomMapName != "anatolia")
      {
        int planID=aiPlanCreate("Train Triremes", cPlanTrain);
         if (planID >= 0)
         {
            aiPlanSetMilitary(planID, true);
			if (cMyCulture == cCultureGreek)
            aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeTrireme);
			if (cMyCulture == cCultureEgyptian)
			aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeKebenit);
			if (cMyCulture == cCultureNorse)
			aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeLongboat);
			if (cMyCulture == cCultureAtlantean)
			aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeBireme);
			if (cMyCulture == cCultureChinese)
			aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeJunk);
            
			aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 1); 
            aiPlanSetActive(planID);
            aiPlanSetDesiredPriority(planID, 20);
			xsDisableSelf();
         }
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
// retreat handler
//==============================================================================
void retreatHandler(int planID = -1)
{
   aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIRetreat, -1);
}

//==============================================================================
// relic handler
//==============================================================================
void relicHandler(int relicID = -1)
{
   if (aiRandInt(30) != 0)
      return;

   for (i=1; < cNumberPlayers)
   {
      if (i == cMyID)
         continue;

      //Only a 33% chance for either of these chats
      if (kbIsPlayerAlly(i) == true)
      {
         if (relicID != -1)
         {
            //We don't need to know where you picked up that damn relic
			
            aiCommsSendStatement(i, cAICommPromptTakingAllyRelic, -1);
         }
         else 
            aiCommsSendStatement(i, cAICommPromptTakingAllyRelic, -1);
      }
      else 
         aiCommsSendStatement(i, cAICommPromptTakingEnemyRelic, -1);
   }
}


  
//==============================================================================
// RULE HuntingDogsAsap
//==============================================================================
rule HuntingDogsAsap
   minInterval 4
   inactive
{
   static int age2Count = 0;

   int HuntingDogsUpgBuilding = cUnitTypeGranary;
   if (cMyCulture == cCultureChinese)
   HuntingDogsUpgBuilding = cUnitTypeStoragePit;
   if (cMyCulture == cCultureAtlantean)
   HuntingDogsUpgBuilding = cUnitTypeGuild;
   
   
      if (cMyCulture != cCultureAtlantean && cMyCulture != cCultureNorse && kbUnitCount(cMyID, HuntingDogsUpgBuilding, cUnitStateAlive) < 1)
	  return;
   
   if (gHuntingDogsASAP == true && aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, cTechHuntingDogs) < 0)
   {
	   //Hunting dogs.
	   int huntingDogsPlanID=aiPlanCreate("getHuntingDogs", cPlanProgression);
	   if (huntingDogsPlanID != 0)
	   {
	   	   aiPlanSetVariableInt(huntingDogsPlanID, cProgressionPlanGoalTechID, 0, cTechHuntingDogs);
		   aiPlanSetDesiredPriority(huntingDogsPlanID, 25);
		   aiPlanSetEscrowID(huntingDogsPlanID, cEconomyEscrowID);
		   aiPlanSetActive(huntingDogsPlanID);
		   xsDisableSelf();
	   }
   } 
}   
  
//==============================================================================
// RULE DONATEFood
//==============================================================================
rule DONATEFood
   minInterval 30
   maxInterval 80
   inactive
   Group Donations
{
  if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
  {
        xsDisableSelf();
        return;    
    }
   for (i = aiRandInt(12); <= cNumberPlayers)
   {
           if (i == cMyID)
         continue;
      
	       float foodSupply = kbResourceGet(cResourceFood);
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && kbHasPlayerLost(i) == false && foodSupply > 1500)
		   {
		             if (ShowAiEcho == true) aiEcho("Tributing 100 food to one of my allies!");
	  aiTribute(i, cResourceFood, 100);
	  }  	
 }
 }
 
 //==============================================================================
// RULE DONATEWood
//==============================================================================
rule DONATEWood
   minInterval 30
   maxInterval 80
   inactive
   Group Donations
{
  if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
  {
        xsDisableSelf();
        return;    
    }
   for (i = aiRandInt(12); <= cNumberPlayers)
   {
           if (i == cMyID)
         continue;
      
	       float woodSupply = kbResourceGet(cResourceWood);
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && kbHasPlayerLost(i) == false && woodSupply > 1750)
		   {
		             if (ShowAiEcho == true) aiEcho("Tributing 100 wood to one of my allies!");
	  aiTribute(i, cResourceWood, 100);
	  return;
	  }  	
 }
 }
 
 //==============================================================================
// RULE DONATEGold
//==============================================================================
rule DONATEGold
   minInterval 30
   maxInterval 80
   inactive
   Group Donations
{
  if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
  {
        xsDisableSelf();
        return;    
    }
   for (i = aiRandInt(12); <= cNumberPlayers)
   {
           if (i == cMyID)
         continue;
      
	       float goldSupply = kbResourceGet(cResourceGold);
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && kbHasPlayerLost(i) == false && goldSupply > 2000)
		   {
		             if (ShowAiEcho == true) aiEcho("Tributing 100 gold to one of my allies!");
	  aiTribute(i, cResourceGold, 100);
	  return;
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
   active
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
   if (secondsUnderAttack < 30)
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
// buildGarden // Stolen from the Expansion. ):
//==============================================================================
rule buildGarden
   minInterval 14
   inactive
{
	if(cMyCulture != cCultureChinese)
	{
		xsDisableSelf();
		return;
	}

	int gardenProtoID = cUnitTypeGarden;

   //If we have any houses that are building, skip.
   if (kbUnitCount(cMyID, gardenProtoID, cUnitStateBuilding) > 0)
	  return;
   
	//If we already have gGardenBuildLimit gardens, we shouldn't build anymore.
   if (gGardenBuildLimit != -1)
   {
	  int numberOfGardens = kbUnitCount(cMyID, gardenProtoID, cUnitStateAliveOrBuilding);
	  if (numberOfGardens >= gGardenBuildLimit)
		 return;
   }
   //If we already have a garden plan active, skip.
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gardenProtoID) > -1)
	  return;

   //Over time, we will find out what areas are good and bad to build in.  Use that info here, because we want to protect houses.
	int planID = aiPlanCreate("BuildGarden", cPlanBuild);
   if (planID >= 0)
   {
	  aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, gardenProtoID);
	  aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
	  aiPlanSetDesiredPriority(planID, 100);

		int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
	  if (cMyCulture == cCultureNorse)
		 builderTypeID = cUnitTypeUlfsark;   // Exact match for land scout, so build plan can steal scout
	  if(cMyCulture == cCultureChinese)
		  builderTypeID = cUnitTypeVillagerChinese; // Temp chinese fix

		aiPlanAddUnitType(planID, builderTypeID, 1, 1, 1);
	  aiPlanSetEscrowID(planID, cEconomyEscrowID);

	  vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));

	  float x = xsVectorGetX(backVector);
	  float z = xsVectorGetZ(backVector);
	  x = x * 40.0;
	  z = z * 40.0;

	  backVector = xsVectorSetX(backVector, x);
	  backVector = xsVectorSetZ(backVector, z);
	  backVector = xsVectorSetY(backVector, 0.0);
	  vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	  int areaGroup1 = kbAreaGroupGetIDByPosition(location);   // Base area group
	  location = location + backVector;
	  int areaGroup2 = kbAreaGroupGetIDByPosition(location);   // Back vector area group
	  if (areaGroup1 != areaGroup2)
		 location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));   // Reset to area center if back is in wrong area group

	  aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 20.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 1.0);

	  aiPlanSetActive(planID);
   }
}

//==============================================================================
// Rule: ChooseGardenResource  // Redefined to fit this Ai better. (Reth)
//==============================================================================
rule ChooseGardenResource
minInterval 20
inactive
{
    float FoodSupply = kbResourceGet(cResourceFood);
    float WoodSupply = kbResourceGet(cResourceWood); 
	float GoldSupply = kbResourceGet(cResourceGold);
    float MyFavor = kbResourceGet(cResourceFavor); 
	
	int res  = cResourceGold;
	string resname = "Gold";
if (FoodSupply < 500)
	{
		res  = cResourceFood;
		resname = "Food";
	}	

	if (WoodSupply < 200 && FoodSupply > 500 && GoldSupply > WoodSupply)
	{
		res  = cResourceWood;
		resname = "Wood";
	}
	
if (GoldSupply < 400 && FoodSupply > 500 && WoodSupply > GoldSupply)
	{
		res  = cResourceGold;
		resname = "Gold";
	}

	if (MyFavor < 60 && FoodSupply > 600 && WoodSupply > 300 && GoldSupply > 600)
	{
		res  = cResourceFavor;
		resname = "Favor";
	}
	
	if (MyFavor < 30 && FoodSupply > 150)
	{
		res  = cResourceFavor;
		resname = "Favor";
	}
	
else if (FoodSupply > 600 && WoodSupply > 300 && GoldSupply > 400 && MyFavor > 60)
{	
    int choice = -1;
    choice = aiRandInt(3);     // 0-3
    
    switch(choice)
    {
        case 0:  // Food
        {
		res  = cResourceFood;
		resname = "Food";
        }
        case 1:  // Wood
        {
		res  = cResourceWood;
		resname = "Wood";
        }
        case 2:  // Gold
        {
		res  = cResourceGold;
		resname = "Gold";
        }	
}
}	
	if (ShowAiEcho == true) aiEcho("Setting gardens to: " + resname);
	kbSetGardenResource(res);
    }		


//==============================================================================
rule getEarthenWall
    inactive
    minInterval 37 //starts in cAge2
{
    int techID = cTechEarthenWall;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsEnableRule("getStoneWall");
        xsDisableSelf();
        return;
    }

    if (ShowAiEcho == true) aiEcho("getEarhernWall:");


    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
        return;
       
    
    if (kbGetTechStatus(techID) == cTechStatusAvailable)
    {
        int x = aiPlanCreate("StoneWall", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 98);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);

    }
}

//==============================================================================
rule getGreatWall
    inactive
//    minInterval 31 //starts in cAge3
    minInterval 37 //starts in cAge2 activated in getStoneWall
{
    int techID = cTechGreatWall;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {		
			
        xsDisableSelf();
        return;
    }
    
    if (ShowAiEcho == true) aiEcho("getGreatWall:");

    if (kbGetTechStatus(cTechStoneWall) < cTechStatusResearching)
    {
        return;
    }

    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    if (numFortresses < 1)
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);    
    if ((goldSupply < 600) || (foodSupply < 750))
        return;
        

    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
    }

    if (kbGetTechStatus(techID) == cTechStatusAvailable)
    {
        int x = aiPlanCreate("GreatWall", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 90);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Great Wall");
    }
}
//==============================================================================
// getNumberUnits
//==============================================================================
int getNumberUnits(int unitType=-1, int playerID=-1, int state=cUnitStateAlive)
{
	int count=-1;
   static int unitQueryID=-1;

   //Create the query if we don't have it yet.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("GetNumberOfUnitsQuery");
   
	//Define a query to get all matching units.
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
      kbUnitQuerySetUnitType(unitQueryID, unitType);
      kbUnitQuerySetState(unitQueryID, state);
	}
	else
   	return(0);

	kbUnitQueryResetResults(unitQueryID);
	return(kbUnitQueryExecute(unitQueryID));
}
//==============================================================================
// RULE: buildManyBuildings (Age of Buildings strategy --- Poseidon ONLY)
//==============================================================================
rule buildManyBuildings
   minInterval 30
   inactive
{
   float currentWood=kbResourceGet(cResourceWood);


   static int unitQueryID=-1;

   if (cMyCiv != cCivPoseidon)
   {
	xsDisableSelf();
	return;
   }
  
   int numberOfArcheryRange=kbUnitCount(cMyID, cUnitTypeArcheryRange, cUnitStateAlive);
   int numberOfBarracks=kbUnitCount(cMyID, cUnitTypeBarracks, cUnitStateAlive);
   int numberOfStables=kbUnitCount(cMyID, cUnitTypeStable, cUnitStateAlive);
   int numberOfFortresses=kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAlive);
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);

   if (numberOfFortresses < 1 || numberSettlements < 2)
      return;

   if (kbGetAge() < 2)
      return;

   if (currentWood < 1000)
      return;

 if (numberOfArcheryRange < 15 || numberOfBarracks < 15 || numberOfStables < 15)
 {
   int planID=aiPlanCreate("Build More Buildings", cPlanBuild);
   if (planID >= 0)
   {
      int randSelect=aiRandInt(3);

      if (randSelect == 0)
	      aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeArcheryRange);
      else if (randSelect == 1)
	      aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeBarracks);
      else
	      aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeStable);

      aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
      aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 0.0);
      aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
      aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
      aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
      aiPlanSetDesiredPriority(planID, 20);
      int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
      aiPlanAddUnitType(planID, builderTypeID, 1, 1, 1);
      aiPlanSetEscrowID(planID, cRootEscrowID);

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Settlement Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractSettlement);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }


   kbUnitQueryResetResults(unitQueryID);
   int numberFound=kbUnitQueryExecute(unitQueryID);
   int unit=kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound));

    int unitBaseID=kbBaseGetMainID(cMyID);
    if (unit != -1)
    {
       //Get new base ID.
       unitBaseID=kbUnitGetBaseID(unit);
    }

      aiPlanSetBaseID(planID, unitBaseID);

      vector location = kbUnitGetPosition(unit);

      vector backVector = kbBaseGetFrontVector(cMyID, unitBaseID);

      float x = xsVectorGetX(backVector);
      float z = xsVectorGetZ(backVector);
      x = x * aiRandInt(40) - 20;
      z = z * aiRandInt(40) - 20;

      backVector = xsVectorSetX(backVector, x);
      backVector = xsVectorSetZ(backVector, z);
      backVector = xsVectorSetY(backVector, 0.0);
      location = location + backVector;
      aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
      aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 10.0);
      aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 1.0);

      aiPlanSetActive(planID);
   }
 }
}

//==============================================================================
// IHateSiege
//==============================================================================
rule IHateSiege
   minInterval 5
   active
   group HateScripts
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeAbstractSiegeWeapon);
	    kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 30);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   
	   int NoArcherPlease = kbUnitQueryGetResult(unitQueryID, i);
        if (kbUnitIsType(NoArcherPlease, cUnitTypeAbstractArcher) || (kbUnitIsType(NoArcherPlease, cUnitTypeAbstractSiegeWeapon)))
            continue;
	   
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
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
   static int unitQueryID=-1;
   static int enemyQueryID=-1;
   static bool RunOnlyOnce = false;
   
   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	xsDisableSelf();
	return;
   }
   
   		if (cMyCulture == cCultureGreek && RunOnlyOnce == false)
		{
		static int Hero1ID = -1;
		static int Hero2ID = -1;
		static int Hero3ID = -1;
		static int Hero4ID = -1;
		if (cMyCiv == cCivZeus)
        {
            Hero1ID = cUnitTypeHeroGreekJason;
            Hero2ID = cUnitTypeHeroGreekOdysseus;
            Hero3ID = cUnitTypeHeroGreekHeracles;
            Hero4ID = cUnitTypeHeroGreekBellerophon;			
        }
        else if (cMyCiv == cCivPoseidon)
        {
            Hero1ID = cUnitTypeHeroGreekTheseus;
            Hero2ID = cUnitTypeHeroGreekHippolyta;
            Hero3ID = cUnitTypeHeroGreekAtalanta;
            Hero4ID = cUnitTypeHeroGreekPolyphemus;			
        }
        else if (cMyCiv == cCivHades)
        {
            Hero1ID = cUnitTypeHeroGreekAjax;
            Hero2ID = cUnitTypeHeroGreekChiron;
            Hero3ID = cUnitTypeHeroGreekAchilles;
            Hero4ID = cUnitTypeHeroGreekPerseus;			
        }
		if (ShowAiEcho == true || ShowAiTestEcho == true) aiEcho("Heroes set");
		RunOnlyOnce = true;
		}

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Hero Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeHero);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeMythUnit);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 24);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   
	    if (cMyCulture != cCultureEgyptian)
		{
	    int NoMeleeHeroPlease = kbUnitQueryGetResult(unitQueryID, i);
	   	int NoFlyingPlease = kbUnitQueryGetResult(enemyQueryID, 0);
		if ((kbUnitIsType(NoFlyingPlease, cUnitTypePegasus) || kbUnitIsType(NoFlyingPlease, cUnitTypeRoc) || kbUnitIsType(NoFlyingPlease, cUnitTypeFlyingMedic) || 
		kbUnitIsType(NoFlyingPlease, cUnitTypeStymphalianBird) || kbUnitIsType(NoFlyingPlease, cUnitTypePhoenix) || kbUnitIsType(NoFlyingPlease, cUnitTypeVermilionBird)))
		{
        if (cMyCulture == cCultureGreek) if (kbUnitIsType(NoMeleeHeroPlease, Hero1ID) || kbUnitIsType(NoMeleeHeroPlease, Hero3ID) || kbUnitIsType(NoMeleeHeroPlease, Hero4ID))    
			continue;
        if (cMyCulture == cCultureNorse) if (kbUnitIsType(NoMeleeHeroPlease, cUnitTypeHeroNorse) || kbUnitIsType(NoMeleeHeroPlease, cUnitTypeHeroRagnorok))    
			continue;
        if (cMyCulture == cCultureAtlantean) if (kbUnitIsType(NoMeleeHeroPlease, cUnitTypeSwordsmanHero) || kbUnitIsType(NoMeleeHeroPlease, cUnitTypeTridentSoldierHero) || 
		kbUnitIsType(NoMeleeHeroPlease, cUnitTypeRoyalGuardHero) || kbUnitIsType(NoMeleeHeroPlease, cUnitTypeMacemanHero) || kbUnitIsType(NoMeleeHeroPlease, cUnitTypeLancerHero))    
			continue;
        if (cMyCulture == cCultureChinese) if (kbUnitIsType(NoMeleeHeroPlease, cUnitTypeHeroChineseMonk))    
			continue;			
	   }
	   }
	   
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
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
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractArcher);
		if ((cMyCulture == cCultureNorse) || (cMyCulture == cCultureEgyptian))
		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeHeroChineseMonk);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 18);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
   }
}



//==============================================================================
// IHateBuildingsHadesSpecial
//==============================================================================
rule IHateBuildingsHadesSpecial
   minInterval 5
   inactive
   group HateScriptsH
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if ((aiGetWorldDifficulty() == cDifficultyEasy) || (cMyCiv != cCivHades))
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeCrossbowman);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeBuilding);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAny);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 34);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   
        if (kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeSettlement) == true || kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeAbstractFarm) == true)
            continue;
	   
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
   }
}

//==============================================================================
// BanditMigdolRemoval // Valley of Kings special
//==============================================================================
rule BanditMigdolRemoval
   minInterval 8
   active
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if (cRandomMapName != "valley of kings")
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 8)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationAny);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeBanditMigdol);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 40);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp > 0 && kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeAbstractSettlement) == false )
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
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
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractArcher);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeAbstractVillager);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 20);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
   }
}

//==============================================================================
// IHateUnderworldPassages
//==============================================================================
rule IHateUnderworldPassages
   minInterval 8
   inactive
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;


   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeTunnel);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 20);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
   }
}


//==============================================================================
// IHateBuildingsBeheAndScarab
//==============================================================================
rule IHateBuildingsBeheAndScarab
   minInterval 6
   inactive
   group Sekhmet
   group Rheia
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;
   static int MythUnit=-1;
   

   if ((aiGetWorldDifficulty() == cDifficultyEasy) || (cMyCulture != cCultureAtlantean && cMyCulture != cCultureEgyptian))
   {
	xsDisableSelf();
	return;
   }
   if (cMyCulture == cCultureAtlantean)
   MythUnit = cUnitTypeBehemoth;
   else MythUnit = cUnitTypeScarab;
   
   if (kbUnitCount(cMyID, MythUnit) < 1)
   xsSetRuleMinIntervalSelf(65);
   else xsSetRuleMinIntervalSelf(6);
   

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			if (cMyCulture == cCultureEgyptian)
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeScarab);
			if (cMyCulture == cCultureAtlantean)
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeBehemoth);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeBuilding);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 26);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   
        if (kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeSettlement) == true || kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeAbstractFarm) == true)
            continue;
	   
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
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
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractSiegeWeapon);			
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeBuilding);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 34);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   
        if (kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeSettlement) == true || kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeAbstractFarm) == true)
            continue;
			
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
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
   static bool checkTeamStatus=true;
   if (checkTeamStatus == true)
   {
      for (i=1; < cNumberPlayers)
      {
         if (i == cMyID)
            continue;
         if (kbIsPlayerMutualAlly(i) == true && kbIsPlayerResigned(i) == false && kbIsPlayerValid(i) == true && kbHasPlayerLost(i) == false)
		 {
         xsEnableRuleGroup("Donations");
		 xsEnableRule("defendAlliedBase");
		 return;
		 }
		 else 
		 xsDisableRuleGroup("Donations"); 
		 xsDisableRule("defendAlliedBase");
	}
}
}

// KOTH COMPLEX

//==============================================================================
rule GetKOTHVault
    minInterval 1 //starts in cAge3
    inactive
{
    if (ShowAiEcho == true) aiEcho("FindVault:");
    static bool GetKothVRun = false;
    static vector KOTHPlace = cInvalidVector;
	if (GetKothVRun == false)
	{
    //Find other islands area group.
	    int gTCUnitID = -1;
	    int TCunitQueryID = kbUnitQueryCreate("findPlentyVault");
        kbUnitQuerySetPlayerRelation(TCunitQueryID, cPlayerRelationAny);
        kbUnitQuerySetUnitType(TCunitQueryID, cUnitTypePlentyVaultKOTH);
        kbUnitQuerySetState(TCunitQueryID, cUnitStateAny);
        kbUnitQueryResetResults(TCunitQueryID);
        int numberFound = kbUnitQueryExecute(TCunitQueryID);
        gKOTHPlentyUnitID = kbUnitQueryGetResult(TCunitQueryID, 0);

		
		KOTHPlace = kbUnitGetPosition(gKOTHPlentyUnitID);
		GetKothVRun = true;
		}



    //Create transport plan to get units to the other island
	vector there = KOTHPlace;
    ClaimKoth(there);
	xsDisableSelf();
}


// Land & water KoTH		

//==============================================================================
rule getKingOfTheHillVault
minInterval 10
inactive
{
               xsSetRuleMinIntervalSelf(30);
			   static bool LandNeedReCalculation = true;
               static bool WaterVersion = false; 			   
               static vector KOTHPlace = cInvalidVector;
               KOTHPlace = kbUnitGetPosition(gKOTHPlentyUnitID);  
               int NumEnemy = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, KOTHPlace, 25.0, true);
               //int NumAllies = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, KOTHPlace, 25.0, true);
               int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, KOTHPlace, 25.0);

			    //aiEcho("ENEMIES:  "+NumEnemy+" ");
                //aiEcho("ALLIES:  "+NumAllies+" ");
                //aiEcho("SELF:  "+NumSelf+" ");
				
			   
			   
			   if (WaterVersion == false)
			   {
			   int numfish = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
			   if (numfish > 1)
			   {
			   WaterVersion = true;
			   //aiEcho("Water version of KOTH detected.");
			   aiPlanDestroy(gDefendPlentyVault);  // never again!
			   return;
               } 
               }			   
                int numAvailableUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
                if (numAvailableUnits < 11 || kbGetPop() <= 29)
                return;
					  
					if (LandNeedReCalculation == true && WaterVersion == false)
					{
					    gDefendPlentyVault = aiPlanCreate("KOTH VAULT DEFEND", cPlanDefend);         // Uses "enemy" plan for allies, too.
                
                        aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeMilitary, NumKOTHEnemies + 10, NumKOTHEnemies + 15, NumKOTHEnemies + 18);    // All mil units

                        aiPlanSetDesiredPriority(gDefendPlentyVault, 60);                       // prio
                        aiPlanSetVariableVector(gDefendPlentyVault, cDefendPlanDefendPoint, 0, KOTHPlace);
                        aiPlanSetVariableFloat(gDefendPlentyVault, cDefendPlanEngageRange, 0, 35.0);
                        aiPlanSetVariableBool(gDefendPlentyVault, cDefendPlanPatrol, 0, false);

                        aiPlanSetVariableFloat(gDefendPlentyVault, cDefendPlanGatherDistance, 0, 40.0);
                        aiPlanSetInitialPosition(gDefendPlentyVault, KOTHPlace);
                        aiPlanSetUnitStance(gDefendPlentyVault, cUnitStanceDefensive);

                        aiPlanSetVariableInt(gDefendPlentyVault, cDefendPlanRefreshFrequency, 0, 60);

                        aiPlanSetNumberVariableValues(gDefendPlentyVault, cDefendPlanAttackTypeID, 2, true);
                        aiPlanSetVariableInt(gDefendPlentyVault, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
                        aiPlanSetVariableInt(gDefendPlentyVault, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
                       

                        aiPlanSetActive(gDefendPlentyVault);
                        LandNeedReCalculation = false;
						return;
						}
			   
			   

               
			   if (NumEnemy + 5 > NumSelf && WaterVersion == false)
		       {
			   NumKOTHEnemies = NumEnemy;
			   LandNeedReCalculation = true;
			   xsSetRuleMinIntervalSelf(2);
			   aiPlanDestroy(gDefendPlentyVault);  // restarting plan
			   return;
				}
				 
				 if (NumSelf > NumEnemy + 17 && WaterVersion == true)
				 {
				 SendBackCount = SendBackCount+1;
				 
				 if (SendBackCount > 4)
				 {
				 xsEnableRule("GetKOTHVault");
				 KoTHOkNow = true;
				 SendBackCount = 0;			 		 
				 }
				 }	 
				 
                 if (NumEnemy + 5 > NumSelf && WaterVersion == true)
                 {
                 NumKOTHEnemies = NumEnemy;
			     aiPlanDestroy(gDefendPlentyVault);
	             xsEnableRule("GetKOTHVault");
				 LandNeedReCalculation = false;
				 xsEnableRule("GatherAroundKOTH");
				 return;
	             }


	   // done
	  }

//==============================================================================	  
rule GatherAroundKOTH
   minInterval 22
   inactive
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;


   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeLogicalTypeLandMilitary);			
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationAny);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypePlentyVaultKOTH);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAny);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 30);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   
        if (kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeSettlement) == true || kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeAbstractFarm) == true)
            continue;
			
	   if (numberFoundTemp > 0)
	   {
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
   }
}

rule WaterKOTHMonitor
minInterval 2
inactive
{

    if (DestroyTransportPlan == true)
	{
	aiPlanDestroyByName("CLAIM THAT KOTH VAULT");
	aiPlanDestroyByName("GO HOME AGAIN");
    aiPlanDestroy(KOTHTransportPlan);
    DestroyTransportPlan = false;	
	}
	else if (DestroyHTransportPlan == true)
	{
	aiPlanDestroyByName("GO HOME AGAIN");	
	aiPlanDestroy(KOTHTHomeTransportPlan);
	DestroyHTransportPlan = false;
	}
    xsDisableSelf();	
}

//Testing ground