//File: AoModAiExtra.xs
//By Retherichus
//here you'll find some code that I've added to the AI, I do plan on putting every change into this file
//eventually, as time goes by, but that ain't so easy!
//I still don't know of how to make calls for anything other than Rules & plans at the moment.
//feel free to change the values of these rules and what not.


//==============================================================================
//PART 1 Int
//Below, you'll find the Plan handler. 
//you don't really want to touch this.
//==============================================================================

extern int fCitadelPlanID = -1;
mutable void retreatHandler(int planID=-1) {}
mutable void relicHandler(int relicID=-1) {}
mutable void wonderDeathHandler(int playerID=-1) { }


//==============================================================================
//PART 2 Bools
//Below, you'll find a few bools I've set up,
//you can turn these on/off as you please, by setting the final value to true or false.
//There's a small description on all of them, to make it a little easier to understand what happens when you set it to true.
//==============================================================================

extern bool gAgeFaster = true;            // This will lower the amount of military units the AI will train in Classical Age, this will allow the Ai to progress faster on reaching Heroic Age.
bool gHuntEarly = true;                   // This will make villagers hunt aggressive animals way earlier, though this can be a little bit dangerous! 
extern bool gHuntingDogsASAP = false;     // (By Zycat) This will research Hunting Dogs ASAP. Note: This will increase the time it takes for the Ai to reach Classical Age, but it'll give a stronger early econ overall.
extern bool CanIChat = true;              // This will allow the Ai to send chat messages, such as asking for help if it's in danger.

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
	
	
	
	if (cMyCulture == cCultureEgyptian)
    xsEnableRule("buildMonuments");
	
	   If (gHuntEarly == True)
		{
		if (cMyCulture == cCultureGreek)
		aiSetMinNumberNeedForGatheringAggressvies(6);      // The number inside of ( ) represents the amount of villagers/units needed.
		if (cMyCulture == cCultureAtlantean)
		aiSetMinNumberNeedForGatheringAggressvies(2);
	    if (cMyCulture == cCultureEgyptian)
		aiSetMinNumberNeedForGatheringAggressvies(5);
		if (cMyCulture == cCultureNorse)
		aiSetMinNumberNeedForGatheringAggressvies(4);
		
	
	    kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 90.0);	
        }
}

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
