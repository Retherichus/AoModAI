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
//you don't really want to touch this.
//==============================================================================

extern int fCitadelPlanID = -1;
extern int gShiftingSandPlanID= -1;
mutable void retreatHandler(int planID=-1) {}
mutable void relicHandler(int relicID=-1) {}
mutable void wonderDeathHandler(int playerID=-1) { }
extern bool ConfirmFish = false;          // Don't change this, It's for extra safety when fishing, and it'll enable itself if fish is found.


//==============================================================================
//PART 2 Bools & Stuff you can change!
//Below, you'll find a few things I've set up,
//you can turn these on/off as you please, by setting the final value to true or false.
//There's also a small description on all of them, to make it a little easier to understand what happens when you set it to true.
//==============================================================================

extern bool gWallsInDM = true;            // This allows the Ai to build walls in the gametype ''Deathmatch''
extern bool gAgeFaster = true;            // This will lower the amount of military units the AI will train in Classical Age, this will allow the Ai to progress faster to Heroic Age, config below.
extern bool gSuperboom = true;            // The Ai will set goals to harvest X Food, X Gold and X Wood at a set timer, see below for conf.
extern bool RethEcoGoals = true;          // Similar to gSuperboom, this will take care of the resources the Ai will try to maintain in Age 2-4, see more below.
extern bool RethFishEco = true;          // Changes the default fishing plan, by forcing early fishing(On fishing maps only). This causes the villagers to go heavy on Wood for the first 2 minutes of the game.


extern bool gHuntEarly = true;            // This will make villagers hunt aggressive animals way earlier, though this can be a little bit dangerous! (Damn you Elephants!) 
extern bool gHuntingDogsASAP = false;     // (By Zycat) This will research Hunting Dogs ASAP. (Note: This will increase the time it takes for the Ai to reach Classical Age, but it'll give a stronger early econ overall.
extern bool CanIChat = true;              // This will allow the Ai to send chat messages, such as asking for help if it's in danger.
extern bool gEarlyMonuments = true;       // This allows the Ai to build Monuments in Archaic Age. Egyptian only.
extern bool bHouseBunkering = true;       // Makes the Ai bunker up towers with Houses.

//For gAgefaster when true.
extern int eMaxMilPop = 30;               // Max military pop cap during Classical Age, the lower it is, the faster it'll advance, but leaving it defenseless can be just as bad!


// If gSuperboom is set to true, the numbers below are what the Ai will attempt to gather in Archaic Age or untill X minutes have passed.
// This can be a bit unstable if you leave it on for more than 4+ min, but it's usually very rewarding. 
// Note: This is always delayed by 2 minutes into the game. this is due to EarlyEcon rules, which release villagers for other tasks at the 2 minute marker.

extern int eBoomFood = 700;              // Food
extern int eBoomGold = 200;              // Gold
extern int eBoomWood = 100;              // Wood, duh.

// For RethFishEco, this affects Fishing Maps ONLY, if you have it enabled.
// If the Ai fails to find any valid fishing spot for any reason, it'll scrap this fishing plan and return to normal resource distribution.

extern int eFBoomFood = 0;              // Food
extern int eFBoomGold = 0;              // Gold
extern int eFBoomWood = 50;             // Wood, The Ai will automatically boost it, if it's too low.


//Timer for gSuperboom & fishing
extern int eBoomTimer = 4;                // Minutes this plan will remain active. It'll disable itself after X minutes set.(minus delay) 
extern int eFishTimer = 2;                // Minutes the Ai will go heavy on Wood, this supports the Ai in building early fishing ships.







// For RethEcoGoals, AoModAi do normally calculate the resources it needs, though.. we want it to keep some extra resources at all times, 
// so let's make it a little bit more ''static'' by setting resource goals a little closer to what Admiral Ai use.
//==============================================================================
//Greek
//==============================================================================
//Age 2 (Classical Age)
extern int RethLGFAge2 = 1000;             // Food
extern int RethLGGAge2 = 700;              // Gold
extern int RethLGWAge2 = 500;              // Wood

//Age 3 (Heroic Age)

extern int RethLGFAge3 = 1200;              // Food
extern int RethLGGAge3 = 1000;              // Gold
extern int RethLGWAge3 = 600;              // Wood

//Age 4 (Mythic Age)

extern int RethLGFAge4 = 1400;              // Food
extern int RethLGGAge4 = 1000;              // Gold
extern int RethLGWAge4 = 700;              // Wood


//==============================================================================
//Egyptian
//==============================================================================

//Age 2 (Classical Age)
extern int RethLEFAge2 = 1000;              // Food
extern int RethLEGAge2 = 800;              // Gold
extern int RethLEWAge2 = 100;              // Wood

//Age 3 (Heroic Age)

extern int RethLEFAge3 = 1300;              // Food
extern int RethLEGAge3 = 1100;              // Gold
extern int RethLEWAge3 = 300;              // Wood

//Age 4 (Mythic Age)

extern int RethLEFAge4 = 1400;              // Food
extern int RethLEGAge4 = 1000;              // Gold
extern int RethLEWAge4 = 500;              // Wood

//==============================================================================
//Norse
//==============================================================================

//Age 2 (Classical Age)
extern int RethLNFAge2 = 1000;             // Food
extern int RethLNGAge2 = 700;              // Gold
extern int RethLNWAge2 = 500;              // Wood

//Age 3 (Heroic Age)

extern int RethLNFAge3 = 1200;              // Food
extern int RethLNGAge3 = 1000;              // Gold
extern int RethLNWAge3 = 600;              // Wood

//Age 4 (Mythic Age)

extern int RethLNFAge4 = 1400;              // Food
extern int RethLNGAge4 = 1000;              // Gold
extern int RethLNWAge4 = 650;              // Wood

//==============================================================================
//Atlantean
//==============================================================================

//Age 2 (Classical Age)
extern int RethLAFAge2 = 1000;              // Food
extern int RethLAGAge2 = 700;              // Gold
extern int RethLAWAge2 = 500;              // Wood

//Age 3 (Heroic Age)

extern int RethLAFAge3 = 1200;              // Food
extern int RethLAGAge3 = 1000;              // Gold
extern int RethLAWAge3 = 650;              // Wood

//Age 4 (Mythic Age)

extern int RethLAFAge4 = 1400;              // Food
extern int RethLAGAge4 = 1000;              // Gold
extern int RethLAWAge4 = 700;              // Wood



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
	
	if (aiIsMultiplayer() == false)
	aiEcho("We're in a singleplayer/offline game, nothing can stop us here!");                 // Just to confirm game mode.
	
	if (aiIsMultiplayer() == true)
	aiEcho("We're in a multiplayer game, I will make sure not to use any De-sync sensitive Godpowers.");  // ^ Ditto, heh.
	
	
	if (cMyCulture == cCultureEgyptian && gEarlyMonuments == true)
    xsEnableRule("buildMonuments");
	
	   if (gHuntEarly == true)
		{
		if (cMyCulture == cCultureGreek)
		aiSetMinNumberNeedForGatheringAggressvies(5);      // The number inside of ( ) represents the amount of villagers/units needed.
		if (cMyCulture == cCultureAtlantean)
		aiSetMinNumberNeedForGatheringAggressvies(2);
	    if (cMyCulture == cCultureEgyptian)
		aiSetMinNumberNeedForGatheringAggressvies(5);
		if (cMyCulture == cCultureNorse)
		aiSetMinNumberNeedForGatheringAggressvies(4);	
        }
}

//==============================================================================
void initRethlAge2(void)
{
	// The Greeks are working as intended, so we're skipping that.
	
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
	   if ((cRandomMapName == "highland") || (cRandomMapName == "nomad"))
	{
	gWaterMap=true;
	ConfirmFish=true;
	xsEnableRule("fishing");
	aiEcho("Fishing enabled for Nomad and Highland map");
	}

	//  Enable Dock defense. 
xsEnableRule("DockDefenseMonitor");
	
}	

//==============================================================================
// RULE ActivateRethOverridesAge 1-4
//==============================================================================
rule ActivateRethOverridesAge1
   minInterval 5
   active
{
        initRethlAge1();
		if (gHuntingDogsASAP == true)
		xsEnableRule("HuntingDogsAsap");
		
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
		
		
		xsDisableSelf();
           
    }
	
rule ActivateRethOverridesAge2
   minInterval 60
   active
{
    if (kbGetAge() > cAge1)
    {
		initRethlAge2();
		xsDisableSelf();
           
    }
}

rule ActivateRethOverridesAge3
   minInterval 60
   active
{
    if (kbGetAge() > cAge2)
    {
        //placeholder.. thanks for noticing!
		
		xsDisableSelf();
           
    }
}

rule ActivateRethOverridesAge4
   minInterval 5
   active
{
    if (kbGetAge() > cAge3)
    {
    xsEnableRule("repairTitanGate");
		
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
            
			aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 1); 
            aiPlanSetActive(planID);
            aiPlanSetDesiredPriority(planID, 50);
			xsDisableSelf();
         }
      }
	   if (gWaterMap == false)
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
   minInterval 15
   inactive
{
   static int age2Count = 0;

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
   active
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
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && foodSupply > 1500)
		   {
		             aiEcho("Tributing 100 food to one of my allies!");
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
   active
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
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && woodSupply > 1750)
		   {
		             aiEcho("Tributing 100 wood to one of my allies!");
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
   active
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
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && goldSupply > 2000)
		   {
		             aiEcho("Tributing 100 gold to one of my allies!");
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
