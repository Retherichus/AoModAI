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
extern int gLandExplorePlanID2=-1;
extern int gLandScoutSpecialUlfsark = -1;
extern bool IsRunTradeUnits1 = false;
extern bool IsRunTradeUnits2 = false;
extern bool IsRunHuntingDogs = false;
extern bool IsRunWallSize = false;
extern int numTeesNearMainBase = -1;
extern int gDefendPlentyVault = -1;
extern int gHeavyGPTech=-1;
extern int gHeavyGPPlan=-1;
extern int gTradeMaintainPlanID=-1;
extern int gDefendPlentyVaultWater=-1;
extern int WallAllyPlanID=-1;
extern bool KOTHStopRefill = false;
extern vector KOTHGlobal = cInvalidVector;
extern bool IhaveAllies = false;
extern bool mRusher = false;
extern int MoreFarms = 28;

//////////////// aiEchoDEBUG ////////////////

extern bool ShowAiEcho = false; // All aiEcho, see specific below to override.
extern bool ShowAiEcoEcho = false;
extern bool ShowAiGenEcho = false;
extern bool ShowAiMilEcho = false;
extern bool ShowAiDefEcho = false;
extern bool ShowAiTestEcho = false;

//////////////// END OF aiEchoDEBUG ///////////

//==============================================================================
//PART 2 Bools & Stuff you can change!
//Below, you'll find a few things I've set up,
//you can turn these on/off as you please, by setting the final value to "true" (on) or "false" (off).
//There's also a small description on all of them, to make it a little easier to understand what happens when you set it to true.
//==============================================================================
extern bool mCanIDefendAllies = true;     // Allows the AI to defend his allies.
extern bool gWallsInDM = true;            // This allows the Ai to build walls in the gametype ''Deathmatch''.
extern bool gAgeFaster = false;            // This will lower/halt most non economical upgrades until Mythic Age, this will allow the Ai to age up faster.
extern int AgeFasterStop = cAge3;         // Age to stop gAgeFaster if enabled. "cAge1" Archaic, "cAge2" Classical, "cAge3" Heroic, "cAge4" Mythic.
extern bool gAgeReduceMil = false;         // This will lower the amount of military units the AI will train until Mythic Age, this will also help the AI to advance a little bit faster, more configs below.
extern bool gSuperboom = true;            // The Ai will set goals to harvest X Food, X Gold and X Wood at a set timer, see below for conf.
extern bool RethEcoGoals = true;          // Similar to gSuperboom, this will take care of the resources the Ai will try to maintain in Age 2-4, see more below.
extern bool RethFishEco = true;          // Changes the default fishing plan, by forcing early fishing(On fishing maps only). This causes the villagers to go heavy on Wood for the first 2 minutes of the game.
extern bool bWallUp = true;              // This ensures that the Ai will build walls(almost always), regardless of personality.
extern bool OneMBDefPlanOnly = true;      // Only allow one active "idle defense plan for Mainbase (6 units, 12 if set to false)"

extern bool ResInflate = true;            // Sets the food multiplier to 1.0 once above 5k food.
extern bool gHuntEarly = true;            // This will make villagers hunt aggressive animals way earlier, though this can be a little bit dangerous! (Damn you Elephants!) 
extern bool CanIChat = true;              // This will allow the Ai to send chat messages, such as asking for help if it's in danger.
extern bool gEarlyMonuments = false;       // This allows the Ai to build Monuments in Archaic Age. Egyptian only.
extern bool bHouseBunkering = true;       // Makes the Ai bunker up towers with Houses.
extern bool bWonderDefense = true;         // Builds towers/fortresses around friendly wonders.
extern bool bWallAllyMB = false;          // Walls up the mainbase of a human ally (don't use this if you plan on having more than 1 AoModAI ally!)
extern bool bWallCleanup = true;          // Prevents the AI from building small wall pieces inside of gates and/or deletes them if one were to slip through the check.
extern bool CheatResources = false;        // For those who finds titan (difficulty) to be just 	too easy, enable this and you'll have the AI cheat in some resources as it ages up.
extern bool mPopLandAttack = true;         //Dynamically scales the min total pop needed before it can attack, 6 pop slots per TC after 4 and beyond.
//For gAgeReduceMil when true.
extern int eMaxMilPop = 15;               // Max military pop cap during Classical Age, the lower it is, the faster it'll advance, but leaving it defenseless can be just as bad!
extern int eHMaxMilPop = 25;              // Heroic age.


// If gSuperboom is set to true, the numbers below are what the Ai will attempt to gather in Archaic Age or untill X minutes have passed.
// This can be a bit unstable if you leave it on for more than 4+ min, but it's usually very rewarding. 
// Note: This is always delayed by 2 minutes into the game. this is due to EarlyEcon rules, which release villagers for other tasks at the 2 minute marker.

extern int eBoomFood = 600;              // Food
extern int eBoomGold = 150;              // Gold
extern int eBoomWood = 200;              // Wood, duh.


//Egyptians have their own, because they don't like wood as much.

extern int egBoomGold = 300;              // Gold
extern int egBoomWood = 0;              // Wood


// For RethFishEco, this affects Fishing Maps ONLY, if you have it enabled.
// If the Ai fails to find any valid fishing spot for any reason, it'll scrap this fishing plan and return to normal resource distribution.

extern int eFBoomFood = 0;              // Food
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
extern int RethLGFAge2 = 850;             // Food
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
extern int RethLNFAge2 = 1000;             // Food
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
	// kbLookAtAllUnitsOnMap();   // Semi cheating!.. Disabled because I hate cheating, you may enable this by removing the double slash (note: all other AIs do cheat)
	
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
	   if ((cRandomMapName == "highland") || ((cRandomMapName == "Sacred Pond") || (cRandomMapName == "Sacred Pond 1.0") || (cRandomMapName == "Sacred Pond 1-0") || (cRandomMapName == "nomad") || (cRandomMapName == "Deep Jungle") || (cRandomMapName == "Mediterranean") || (cRandomMapName == "mediterranean")))
	   {
	   gTransportMap=false;
	   if (ShowAiEcho == true) aiEcho("Not going to waste pop slots on Transport ships.");
	   }

	   if (cMyCulture == cCultureChinese)
	   {
	   if (cRandomMapName == "vinlandsaga" || cRandomMapName == "team migration")
	   {
	   int areaID=kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
	   aiUnitCreateCheat(cMyID, cUnitTypeTransportShipChinese, kbAreaGetCenter(areaID), "Spawn missing boat", 1);
	   xsEnableRule("StartingBoatFailsafe");
	   }
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
	
	if (cRandomMapName == "valley of kings")
	xsEnableRule("BanditMigdolRemoval");
	

	//  Enable Dock defense. 
    xsEnableRule("DockDefenseMonitor");
    //HateScripts
    xsEnableRuleGroup("HateScripts");
	
	// Check with allies and enable donations
    xsEnableRule("MonitorAllies");
	
	if (bWallAllyMB == true)
	xsEnableRule("WallAllyMB");
	
	if (bWallCleanup == true)
	xsEnableRuleGroup("WallCleanup");
	
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
		
	    if (CheatResources == true)
	    {
        aiResourceCheat(cMyID, cResourceFood, 300);
	    aiResourceCheat(cMyID, cResourceWood, 250);
	    aiResourceCheat(cMyID, cResourceGold, 300);
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
		
		if (cMyCiv != cCivThor)
        xsEnableRuleGroup("ArmoryAge2");
        if (cMyCiv == cCivThor)
        xsEnableRuleGroup("ArmoryThor");
		
		if (cMyCiv == cCivPoseidon)
		xsEnableRule("buildManyBuildings");
		
	    if (CheatResources == true)
	    {
        aiResourceCheat(cMyID, cResourceFood, 600);
	    aiResourceCheat(cMyID, cResourceWood, 500);
	    aiResourceCheat(cMyID, cResourceGold, 600);
	    }		
		
		mRusher = false;
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
		if (aiGetWorldDifficulty() > cDifficultyModerate && (aiGetGameMode() != cGameModeDeathmatch))
		xsEnableRule("randomUpgrader");
		
	    if (CheatResources == true)
	    {
        aiResourceCheat(cMyID, cResourceFood, 800);
	    aiResourceCheat(cMyID, cResourceWood, 800);
	    aiResourceCheat(cMyID, cResourceGold, 900);
	    }		
		
		xsDisableSelf();
           
    }
}	


//==============================================================================
// rule DockDefenseMonitor // I'll make this more dynamic later and base it on enemy ships.
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
   
         if (gWaterMap == true && kbGetAge() > cAge1 && cRandomMapName != "sudden death" && cRandomMapName != "anatolia" && cRandomMapName != "basin")
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
            aiPlanSetDesiredPriority(planID, 1);
         }
      }

	  xsDisableSelf();
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
   inactive
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
		 IhaveAllies = true;
		 return;
		 }
		 else 
		 xsDisableRuleGroup("Donations"); 
		 xsDisableRule("defendAlliedBase");
		 IhaveAllies = false;
	}
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
	
    int baseID=-1;
    int startAreaID=-1;
    static vector KOTHPlace = cInvalidVector;
    KOTHPlace = kbUnitGetPosition(gKOTHPlentyUnitID);	
	int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, KOTHPlace, 25.0);
    
    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
	
	if (cMyCulture == cCultureGreek)
	transportPUID = cUnitTypeTransportShipGreek;
	else if (cMyCulture == cCultureNorse)
	transportPUID = cUnitTypeTransportShipNorse;
	else if (cMyCulture == cCultureAtlantean)
	transportPUID = cUnitTypeTransportShipAtlantean;
	else if (cMyCulture == cCultureChinese)
	transportPUID = cUnitTypeTransportShipChinese;

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

    // user specified a base, use it!
    if ( baseToUseID != -1 )
    {
        baseID = baseToUseID;
    }
    
    

    if ( baseID == -1 ) // no base found, use mainbase!
    {
        baseID = kbBaseGetMainID(cMyID);
    }

    vector baseLoc = kbBaseGetLocation(cMyID, baseID); 
    startAreaID = kbAreaGetIDByPosition(baseLoc);
    
	
	int ActiveTransportPlans = aiPlanGetNumber(cPlanTransport, -1, true);
	//aiEcho("ActiveTransportPlans:  "+ActiveTransportPlans+" ");
    if (ActiveTransportPlans >= 1)
	{
     if (ShowAiEcho == true) aiEcho("I have 1 active transport plan, returning.");
	 return;
    }
	// prepare other units too
	
	
	if (KoTHOkNow == true)
    {
    KOTHTHomeTransportPlan=createTransportPlan("GO HOME AGAIN", kbAreaGetIDByPosition(where), startAreaID,
                                                      false, transportPUID, 97, kbAreaGetIDByPosition(where));
	aiPlanAddUnitType(KOTHTHomeTransportPlan, cUnitTypeHumanSoldier, 3, 6, 10);
	//aiPlanAddUnitType(KOTHTHomeTransportPlan, HeroType, 1, 1, 4);
    KoTHOkNow = false;
	if (ShowAiEcho == true) aiEcho("GO HOME TRIGGERED");
    return;													  
    }
    else 
	{
    KOTHTransportPlan=createTransportPlan("TRANSPORT TO KOTH VAULT", startAreaID, kbAreaGetIDByPosition(where), false, transportPUID, 80, baseID);

    // add the units to the transport plan

	
	int numAvailableUnits = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    numAvailableUnits = numAvailableUnits-NumSelf;
	
	
	if (kbGetTechStatus(cTechEnclosedDeck) < cTechStatusActive)
	aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 6, 10, 10);
	else if (numAvailableUnits < 15 && kbGetTechStatus(cTechEnclosedDeck) == cTechStatusActive)
    aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 10, 12, 15);
	else aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 12, 16, 20);
	
	
	if (ShowAiEcho == true) aiEcho("GO TO VAULT TRIGGERED");
	}
    //Done
	// Never use cUnitTypeLogicalTypeLandMilitary, Stymphalian Birds and other birds in general, are considered a land unit and will crash the game.
	}

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

//==============================================================================
rule getKingOfTheHillVault
minInterval 10
inactive
{
               static bool LandActive = false;
			   static bool LandNeedReCalculation = false;
               static bool WaterVersion = false; 
               if (WaterVersion == true)
               xsSetRuleMinIntervalSelf(30+aiRandInt(12));
			   else
			   xsSetRuleMinIntervalSelf(20+aiRandInt(12));
			   
               static vector KOTHPlace = cInvalidVector;
               KOTHPlace = kbUnitGetPosition(gKOTHPlentyUnitID);
			   KOTHGlobal = kbUnitGetPosition(gKOTHPlentyUnitID);
               int NumEnemy = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, KOTHPlace, 30.0, true);
               //int NumAllies = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, KOTHPlace, 25.0, true);
               int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, KOTHPlace, 20.0);

			    //aiEcho("ENEMIES:  "+NumEnemy+" ");
                //aiEcho("ALLIES:  "+NumAllies+" ");
                //aiEcho("SELF:  "+NumSelf+" ");
				
			   
			   
			   if (WaterVersion == false)
			   {
			   int numfish = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
			   if (numfish > 1)
			   {
			   WaterVersion = true;
			   if (ShowAiEcho == true) aiEcho("Water version of KOTH detected.");
			   DestroyKOTHLandPlan = true;  // never again!
			   xsEnableRule("KOTHMonitor");
			   return;
               } 
               }			   
                int numAvailableUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
				if (WaterVersion == true)
				numAvailableUnits = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
				
				if (WaterVersion == true)
				numAvailableUnits = numAvailableUnits-NumSelf;
				else numAvailableUnits = numAvailableUnits;
                
				if (WaterVersion == true)
				{
				if (numAvailableUnits < 6 && kbGetPop() <= 39 || kbGetAge() < cAge2)
                return;
				}
				
				if (WaterVersion == false)
				{
				if ((numAvailableUnits < 7 && kbGetPop() <= 39) || (kbGetAge() < cAge2) || (numAvailableUnits < 11 && (xsGetTime() > 17*60*1000)))
                return;
				}	  
					if (LandNeedReCalculation == true && WaterVersion == false)
					{
					
			        if (LandActive == false)
					{
					    gDefendPlentyVault = aiPlanCreate("KOTH VAULT DEFEND", cPlanDefend);         // Uses "enemy" plan for allies, too.
                
                        aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeLogicalTypeLandMilitary, numAvailableUnits * 0.7, numAvailableUnits * 0.8, numAvailableUnits * 0.85);    // Most mil units.

                        aiPlanSetDesiredPriority(gDefendPlentyVault, 70);                       // prio
                        aiPlanSetVariableVector(gDefendPlentyVault, cDefendPlanDefendPoint, 0, KOTHPlace);
                        aiPlanSetVariableFloat(gDefendPlentyVault, cDefendPlanEngageRange, 0, 30.0);
                        aiPlanSetVariableBool(gDefendPlentyVault, cDefendPlanPatrol, 0, false);

                        aiPlanSetVariableFloat(gDefendPlentyVault, cDefendPlanGatherDistance, 0, 10.0);
                        aiPlanSetInitialPosition(gDefendPlentyVault, KOTHPlace);
                        aiPlanSetUnitStance(gDefendPlentyVault, cUnitStanceDefensive);

                        aiPlanSetVariableInt(gDefendPlentyVault, cDefendPlanRefreshFrequency, 0, 10);

                        aiPlanSetNumberVariableValues(gDefendPlentyVault, cDefendPlanAttackTypeID, 2, true);
                        aiPlanSetVariableInt(gDefendPlentyVault, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
                        aiPlanSetVariableInt(gDefendPlentyVault, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
                        keepUnitsWithinRange(gDefendPlentyVault, KOTHPlace);
                        aiPlanSetNoMoreUnits(gDefendPlentyVault, false);
                        aiPlanSetActive(gDefendPlentyVault);
						KOTHStopRefill = true;
						xsEnableRule("KOTHMonitor"); // lock the first wave
                        LandNeedReCalculation = false;
						
						LandActive = true; // active, will add more units below.
						return;
						}
						aiPlanSetNoMoreUnits(gDefendPlentyVault, false);
						aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeLogicalTypeLandMilitary, numAvailableUnits * 0.8, numAvailableUnits * 0.85, numAvailableUnits * 0.9);    // Most mil units.
						LandNeedReCalculation = false;
						KOTHStopRefill = true;
						xsEnableRule("KOTHMonitor");
						keepUnitsWithinRange(gDefendPlentyVault, KOTHPlace);
						return;
						}
			   
			   

               
			   if (NumEnemy + 15 > NumSelf && WaterVersion == false)
		       {
			   LandNeedReCalculation = true;
			   xsSetRuleMinIntervalSelf(2);
			   //aiPlanDestroy(gDefendPlentyVault);  // restarting plan
			   return;
				}
				
				if (WaterVersion == false)
				return;  // will this skip the code below?
				 
				 if (NumSelf > NumEnemy + 14 && WaterVersion == true)
				 SendBackCount = SendBackCount+1;
				 
				 if (SendBackCount > 6)
				 {
				 xsEnableRule("GetKOTHVault");
				 KoTHOkNow = true;
				 SendBackCount = 0;
                 return;				 
				 }
				 	 
				 
                 if (14 > NumSelf && WaterVersion == true)
                 {
	             xsEnableRule("GetKOTHVault");
				 LandNeedReCalculation = false;
				 xsEnableRule("GatherAroundKOTH");
				 return;
	             }


	   // done
	  }

//==============================================================================	  
rule GatherAroundKOTH  // launches a defend plan on the island.
   minInterval 22
   inactive
{
   static vector KOTHPlace = cInvalidVector;
   KOTHPlace = kbUnitGetPosition(gKOTHPlentyUnitID);
   static bool PlanActive = false;   
   int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, KOTHPlace, 30.0);
   
   if (NumSelf <= 0)
   return;
	   
		if (PlanActive == false)
		{
		if (ShowAiEcho == true) aiEcho("I was here!");
		gDefendPlentyVaultWater = aiPlanCreate("KOTH WATER VAULT DEFEND", cPlanDefend);
                
        

        aiPlanSetDesiredPriority(gDefendPlentyVaultWater, 90);                       // prio
        aiPlanSetVariableVector(gDefendPlentyVaultWater, cDefendPlanDefendPoint, 0, KOTHPlace);
        aiPlanSetVariableFloat(gDefendPlentyVaultWater, cDefendPlanEngageRange, 0, 25.0);
        aiPlanSetVariableBool(gDefendPlentyVaultWater, cDefendPlanPatrol, 0, false);

        aiPlanSetVariableFloat(gDefendPlentyVaultWater, cDefendPlanGatherDistance, 0, 12.0);
        aiPlanSetInitialPosition(gDefendPlentyVaultWater, KOTHPlace);
        aiPlanSetUnitStance(gDefendPlentyVaultWater, cUnitStanceDefensive);

        aiPlanSetVariableInt(gDefendPlentyVaultWater, cDefendPlanRefreshFrequency, 0, 10);

        aiPlanSetNumberVariableValues(gDefendPlentyVaultWater, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(gDefendPlentyVaultWater, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(gDefendPlentyVaultWater, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
        keepUnitsWithinRange(gDefendPlentyVaultWater, KOTHPlace);

        aiPlanSetActive(gDefendPlentyVaultWater);
		PlanActive = true;
		}
		if (PlanActive == true)
		{
		aiPlanAddUnitType(gDefendPlentyVaultWater, cUnitTypeLogicalTypeLandMilitary, NumSelf, NumSelf, NumSelf);
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
	 keepUnitsWithinRange(gDefendPlentyVault, KOTHGlobal);
	 KOTHStopRefill = false;
	 return;
	}
    	
    if (DestroyTransportPlan == true)
	{
	aiPlanDestroyByName("TRANSPORT TO KOTH VAULT");
	aiPlanDestroyByName("GO HOME AGAIN");
    aiPlanDestroy(KOTHTransportPlan);
    DestroyTransportPlan = false;	
	}
	else if (DestroyHTransportPlan == true)
	{
	aiPlanDestroyByName("GO HOME AGAIN");	
	aiPlanDestroy(KOTHTHomeTransportPlan);
	aiPlanDestroyByName("TRANSPORT TO KOTH VAULT");  // just destroy both, as they seem to get stuck.
	aiPlanDestroy(KOTHTransportPlan);
	DestroyHTransportPlan = false;
	}
	else if (DestroyKOTHLandPlan == true)
	{
	aiPlanDestroyByName("KOTH VAULT DEFEND");	
	aiPlanDestroy(gDefendPlentyVault);
	DestroyKOTHLandPlan = false;
	}
    xsDisableSelf();
	
}
// KOTH COMPLEX END
//==============================================================================
rule StartingBoatFailsafe  // for vinlandsaga and team migration where ships may fail to spawn, will also scout the mainland.
minInterval 5
inactive
{
 vector HomeBase = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
 int boats = kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive);
 static int TransportUnit=-1;
 static bool CheckCenter = false;
 static bool Spawned = false;
 if ((boats <= 0) && (Spawned == false))
 {
 aiUnitCreateCheat(cMyID, cUnitTypeRoc, HomeBase, "Spawn backup roc", 1);
 Spawned = true;
 return;
 }
 if ((CheckCenter == false) && (boats >= 1))
 {
 int transportPUID=cUnitTypeTransport;
 vector nearCenter = kbGetMapCenter();
        TransportUnit = findUnit(transportPUID);
        nearCenter = kbGetMapCenter();
        nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;
        nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   
        aiTaskUnitMove(TransportUnit, nearCenter);
		CheckCenter = true;
		}	
 
 xsDisableSelf();
 
}

//==============================================================================
rule RemoveWConnectors
minInterval 5
group WallCleanup
inactive
{

   static int unitQueryID=-1;
   static int enemyQueryID=-1;
   xsSetRuleMinIntervalSelf(5);

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeGate);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
			kbUnitQuerySetAscendingSort(unitQueryID, false);
			kbUnitQuerySetMaximumDistance(unitQueryID, 0);
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
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationSelf);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeWallConnector);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAliveOrBuilding);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 4);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp >= 1)
	   {
	    xsSetRuleMinIntervalSelf(2);
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitDelete(enemyUnitIDTemp);
		if (ShowAiEcho == true || ShowAiTestEcho == true) aiEcho("I deleted cUnitTypeWallConnector");
	   }
   }
}

//==============================================================================
rule RemoveWMedium
minInterval 20
group WallCleanup
inactive
{

   static int unitQueryID=-1;
   static int enemyQueryID=-1;
   xsSetRuleMinIntervalSelf(15);

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeGate);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
			kbUnitQuerySetAscendingSort(unitQueryID, false);
			kbUnitQuerySetMaximumDistance(unitQueryID, 0);
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
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationSelf);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeWallMedium);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAliveOrBuilding);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 4);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp >= 1)
	   {
	    xsSetRuleMinIntervalSelf(2);
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitDelete(enemyUnitIDTemp);
		if (ShowAiEcho == true) aiEcho("Removing a piece of cUnitTypeWallMedium");
	   }
   }
}
//==============================================================================
rule RemoveWShort
minInterval 20
group WallCleanup
inactive
{

   static int unitQueryID=-1;
   static int enemyQueryID=-1;
   xsSetRuleMinIntervalSelf(15);

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeGate);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
			kbUnitQuerySetAscendingSort(unitQueryID, false);
			kbUnitQuerySetMaximumDistance(unitQueryID, 0);
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
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationSelf);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeWallShort);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAliveOrBuilding);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 4);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp >= 1)
	   {
	    xsSetRuleMinIntervalSelf(2);
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitDelete(enemyUnitIDTemp);
		if (ShowAiEcho == true || ShowAiTestEcho == true) aiEcho("Removing a piece of cUnitTypeWallShort");
	   }
   }
}
//==============================================================================
rule RemoveWLong  
minInterval 20
group WallCleanup
inactive
{

   static int unitQueryID=-1;
   static int enemyQueryID=-1;
   xsSetRuleMinIntervalSelf(15);

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeGate);
	        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
			kbUnitQuerySetAscendingSort(unitQueryID, false);
			kbUnitQuerySetMaximumDistance(unitQueryID, 0);
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
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationSelf);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeWallLong);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAliveOrBuilding);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 4);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp >= 1)
	   {
	    xsSetRuleMinIntervalSelf(2);
		enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
		aiTaskUnitDelete(enemyUnitIDTemp);
		if (ShowAiEcho == true || ShowAiTestEcho == true) aiEcho("Removing a piece of cUnitTypeWallLong");
	   }
   }
}

//Testing ground

rule TEST  
minInterval 5
inactive
{

}