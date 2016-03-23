//File: StinnerV.xs


// This applies to Titan only!

extern int gTitanTradeCarts = 13;         // Max trade carts for Titan (+5)

extern int mGoldBeforeTrade = 6500;       //Excess gold to other resources, Also affects Hard Difficulty, because it is nice.

extern bool HardFocus = false;    // Please set this to true if you want the AI to focus the player with most units.

extern bool DisallowPullBack = false;  // set true to make the AI no longer retreat.
// TC stuff

extern int ModdedTCTimer = 25;
extern bool AllyTcLimit = true; // This enables the modified rule and disables the original one.
 


//Eco/escrow goal for all ages.
//Classical Age is non functional, as it can mess up severely with Age up.
//==============================================================================
//Greek
//==============================================================================
//Age 2 (Classical Age)
extern int TRethLGFAge2 = 3000;             // Food
extern int TRethLGGAge2 = 1500;              // Gold
extern int TRethLGWAge2 = 2500;              // Wood

//Age 3 (Heroic Age)

extern int TRethLGFAge3 = 6000;              // Food
extern int TRethLGGAge3 = 3000;              // Gold
extern int TRethLGWAge3 = 5000;              // Wood

//Age 4 (Mythic Age)

extern int TRethLGFAge4 = 12000;              // Food
extern int TRethLGGAge4 = 9000;              // Gold
extern int TRethLGWAge4 = 10000;              // Wood


//==============================================================================
//Egyptian
//==============================================================================

//Age 2 (Classical Age)
extern int TRethLEFAge2 = 2000;              // Food
extern int TRethLEGAge2 = 3000;              // Gold
extern int TRethLEWAge2 = 1000;              // Wood

//Age 3 (Heroic Age)

extern int TRethLEFAge3 = 4000;              // Food
extern int TRethLEGAge3 = 6000;              // Gold
extern int TRethLEWAge3 = 2000;              // Wood

//Age 4 (Mythic Age)

extern int TRethLEFAge4 = 8000;              // Food
extern int TRethLEGAge4 = 12000;              // Gold
extern int TRethLEWAge4 = 4000;              // Wood

//==============================================================================
//Norse
//==============================================================================

//Age 2 (Classical Age)
extern int TRethLNFAge2 = 2500;             // Food
extern int TRethLNGAge2 = 2000;              // Gold
extern int TRethLNWAge2 = 2000;              // Wood

//Age 3 (Heroic Age)

extern int TRethLNFAge3 = 5000;              // Food
extern int TRethLNGAge3 = 4000;              // Gold
extern int TRethLNWAge3 = 4000;              // Wood

//Age 4 (Mythic Age)

extern int TRethLNFAge4 = 10000;              // Food
extern int TRethLNGAge4 = 8000;              // Gold
extern int TRethLNWAge4 = 8000;              // Wood

//==============================================================================
//Atlantean
//==============================================================================

//Age 2 (Classical Age)
extern int TRethLAFAge2 = 3000;              // Food
extern int TRethLAGAge2 = 1500;              // Gold
extern int TRethLAWAge2 = 2500;              // Wood

//Age 3 (Heroic Age)

extern int TRethLAFAge3 = 6000;              // Food
extern int TRethLAGAge3 = 3000;              // Gold
extern int TRethLAWAge3 = 5000;              // Wood

//Age 4 (Mythic Age)

extern int TRethLAFAge4 = 12000;              // Food
extern int TRethLAGAge4 = 6000;              // Gold
extern int TRethLAWAge4 = 10000;              // Wood


//==============================================================================
//Chinese
//==============================================================================

//Age 2 (Classical Age)
extern int TRethLCFAge2 = 3000;              // Food
extern int TRethLCGAge2 = 1500;              // Gold
extern int TRethLCWAge2 = 2500;              // Wood

//Age 3 (Heroic Age)

extern int TRethLCFAge3 = 6000;              // Food
extern int TRethLCGAge3 = 3000;              // Gold
extern int TRethLCWAge3 = 5000;              // Wood

//Age 4 (Mythic Age)

extern int TRethLCFAge4 = 12000;              // Food
extern int TRethLCGAge4 = 6000;              // Gold
extern int TRethLCWAge4 = 10000;              // Wood



// RULES

// These will get automatically activated if on Titan mode.

//==============================================================================
// RULE DONATEMassiveFood
//==============================================================================
rule DONATEMASSFood
   minInterval 15
   maxInterval 40
   inactive
   group MassDonations
{
if ((aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy) || (aiGetWorldDifficulty() < cDifficultyNightmare))
  {
        xsDisableSelf();
        return;    
    }
   for (i = aiRandInt(12); <= cNumberPlayers)
   {
           if (i == cMyID)
         continue;
      
	       float foodSupply = kbResourceGet(cResourceFood);
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && foodSupply > 5000)
		   {
		             aiEcho("Tributing 1000 food to one of my allies!");
	  aiTribute(i, cResourceFood, 1000);
	  }  	
 }
 }
 
 //==============================================================================
// RULE DONATEMassiveWood
//==============================================================================
rule DONATEMASSWood
   minInterval 15
   maxInterval 40
   inactive
   group MassDonations
{
if ((aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy) || (aiGetWorldDifficulty() < cDifficultyNightmare))
  {
        xsDisableSelf();
        return;    
    }
   for (i = aiRandInt(12); <= cNumberPlayers)
   {
           if (i == cMyID)
         continue;
      
	       float woodSupply = kbResourceGet(cResourceWood);
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && woodSupply > 3500)
		   {
		             aiEcho("Tributing 750 wood to one of my allies!");
	  aiTribute(i, cResourceWood, 750);
	  return;
	  }  	
 }
 }
 
 //==============================================================================
// RULE DONATEMassiveGold
//==============================================================================
rule DONATEMASGold
   minInterval 15
   maxInterval 40
   inactive
   group MassDonations
{
if ((aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy) || (aiGetWorldDifficulty() < cDifficultyNightmare))
  {
        xsDisableSelf();
        return;    
    }
   for (i = aiRandInt(12); <= cNumberPlayers)
   {
           if (i == cMyID)
         continue;
      
	       float goldSupply = kbResourceGet(cResourceGold);
	  	   if(kbIsPlayerAlly(i) == true && kbIsPlayerResigned(i) == false && goldSupply > 5000)
		   {
		             aiEcho("Tributing 1000 gold to one of my allies!");
	  aiTribute(i, cResourceGold, 1000);
	  return;
	  }  	
 }
 }
 
 
 //==============================================================================
// CountEnemyUnitsOnMap
//==============================================================================
rule CountEnemyUnitsOnMap
   minInterval 45
   inactive
{
   //Units
   static int unitQueryID1=-1;
   static int unitQueryID2=-1;
   static int unitQueryID3=-1;
   static int unitQueryID4=-1;
   static int unitQueryID5=-1;
   static int unitQueryID6=-1;
   static int unitQueryID7=-1;
   static int unitQueryID8=-1;
   static int unitQueryID9=-1;
   static int unitQueryID10=-1;
   static int unitQueryID11=-1;
   static int unitQueryID12=-1;
   
   // Buildings
   static int BuildingunitQueryID1=-1;
   static int BuildingunitQueryID2=-1;
   static int BuildingunitQueryID3=-1;
   static int BuildingunitQueryID4=-1;
   static int BuildingunitQueryID5=-1;
   static int BuildingunitQueryID6=-1;
   static int BuildingunitQueryID7=-1;
   static int BuildingunitQueryID8=-1;
   static int BuildingunitQueryID9=-1;
   static int BuildingunitQueryID10=-1;
   static int BuildingunitQueryID11=-1;
   static int BuildingunitQueryID12=-1;

  // kbLookAtAllUnitsOnMap(); // enable for testing all units, including non visible.

   if (aiGetWorldDifficulty() < cDifficultyNightmare)
   {
	xsDisableSelf();
	return;
   }


   //Units for Player 1
   if (unitQueryID1 < 0)
   unitQueryID1=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID1 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID1, 1);
		kbUnitQuerySetUnitType(unitQueryID1, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID1, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID1, true);
			
   }
if (kbIsPlayerEnemy(1) && kbIsPlayerValid(1))
{
   kbUnitQueryResetResults(unitQueryID1);
   int Units1=kbUnitQueryExecute(unitQueryID1);
  }

   //Units for Player 2
   if (unitQueryID2 < 0)
   unitQueryID2=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID2 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID2, 2);
		kbUnitQuerySetUnitType(unitQueryID2, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID2, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID2, true);
			
   }
if (kbIsPlayerEnemy(2) && kbIsPlayerValid(2))
{
   kbUnitQueryResetResults(unitQueryID2);
   int Units2=kbUnitQueryExecute(unitQueryID2);
  }

   //Units for Player 3
   if (unitQueryID3 < 0)
   unitQueryID3=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID3 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID3, 3);
		kbUnitQuerySetUnitType(unitQueryID3, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID3, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID3, true);
			
   }
if (kbIsPlayerEnemy(3) && kbIsPlayerValid(3))
   {
int Units3=kbUnitQueryExecute(unitQueryID3);
   kbUnitQueryResetResults(unitQueryID3);
  }
  
  
   //Units for Player 4
   if (unitQueryID4 < 0)
   unitQueryID4=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID4 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID4, 4);
		kbUnitQuerySetUnitType(unitQueryID4, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID4, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID4, true);
			
   }
if (kbIsPlayerEnemy(4) && kbIsPlayerValid(4))
   {
int Units4=kbUnitQueryExecute(unitQueryID4);
   kbUnitQueryResetResults(unitQueryID4);
  }
  
   //Units for Player 5
   if (unitQueryID5 < 0)
   unitQueryID5=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID5 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID5, 5);
		kbUnitQuerySetUnitType(unitQueryID5, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID5, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID5, true);
			
   }
if (kbIsPlayerEnemy(5) && kbIsPlayerValid(5))
   {
int Units5=kbUnitQueryExecute(unitQueryID5);
   kbUnitQueryResetResults(unitQueryID5);
  }
  
   //Units for Player 6
   if (unitQueryID6 < 0)
   unitQueryID6=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID6 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID6, 6);
		kbUnitQuerySetUnitType(unitQueryID6, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID6, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID6, true);
			
   }
if (kbIsPlayerEnemy(6) && kbIsPlayerValid(6))
   {
int Units6=kbUnitQueryExecute(unitQueryID6);
   kbUnitQueryResetResults(unitQueryID6);
  }
  
   //Units for Player 7
   if (unitQueryID7 < 0)
   unitQueryID7=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID7 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID7, 7);
		kbUnitQuerySetUnitType(unitQueryID7, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID7, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID7, true);
			
   }
if (kbIsPlayerEnemy(7) && kbIsPlayerValid(7))
   {
int Units7=kbUnitQueryExecute(unitQueryID7);
   kbUnitQueryResetResults(unitQueryID7);
  }
  
   //Units for Player 8
   if (unitQueryID8 < 0)
   unitQueryID8=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID8 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID8, 8);
		kbUnitQuerySetUnitType(unitQueryID8, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID8, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID8, true);
			
   }
if (kbIsPlayerEnemy(8) && kbIsPlayerValid(8))
   {
int Units8=kbUnitQueryExecute(unitQueryID8);
   kbUnitQueryResetResults(unitQueryID8);
  }
  
   //Units for Player 9
   if (unitQueryID9 < 0)
   unitQueryID9=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID9 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID9, 9);
		kbUnitQuerySetUnitType(unitQueryID9, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID9, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID9, true);
			
   }
if (kbIsPlayerEnemy(9) && kbIsPlayerValid(9))
   {
int Units9=kbUnitQueryExecute(unitQueryID9);
   kbUnitQueryResetResults(unitQueryID9);
  }
  
   //Units for Player 10
   if (unitQueryID10 < 0)
   unitQueryID10=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID10 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID10, 10);
		kbUnitQuerySetUnitType(unitQueryID10, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID10, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID10, true);
			
   }
if (kbIsPlayerEnemy(10) && kbIsPlayerValid(10))
   {
int Units10=kbUnitQueryExecute(unitQueryID10);
   kbUnitQueryResetResults(unitQueryID10);
  }
  
   //Units for Player 11
   if (unitQueryID11 < 0)
   unitQueryID11=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID11 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID11, 11);
		kbUnitQuerySetUnitType(unitQueryID11, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID11, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID11, true);
			
   }
if (kbIsPlayerEnemy(11) && kbIsPlayerValid(11))
   {
int Units11=kbUnitQueryExecute(unitQueryID11);
   kbUnitQueryResetResults(unitQueryID11);
  }
  
   //Units for Player 12
   if (unitQueryID12 < 0)
   unitQueryID12=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (unitQueryID12 != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID12, 12);
		kbUnitQuerySetUnitType(unitQueryID12, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(unitQueryID12, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(unitQueryID12, true);
			
   }
if (kbIsPlayerEnemy(12) && kbIsPlayerValid(12))
   {
int Units12=kbUnitQueryExecute(unitQueryID12);
   kbUnitQueryResetResults(unitQueryID12);
  }


  // Building queries.. yaay!
    //BuildingUnits for Player 1
   if (BuildingunitQueryID1 < 0)
   BuildingunitQueryID1=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID1 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID1, 1);
		kbUnitQuerySetUnitType(BuildingunitQueryID1, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID1, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID1, true);
			
   }
if (kbIsPlayerEnemy(1) && kbIsPlayerValid(1))
{
   kbUnitQueryResetResults(BuildingunitQueryID1);
   int BuildingUnits1=kbUnitQueryExecute(BuildingunitQueryID1);
  }

   //BuildingUnits for Player 2
   if (BuildingunitQueryID2 < 0)
   BuildingunitQueryID2=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID2 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID2, 2);
		kbUnitQuerySetUnitType(BuildingunitQueryID2, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID2, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID2, true);
			
   }
if (kbIsPlayerEnemy(2) && kbIsPlayerValid(2))
{
   kbUnitQueryResetResults(BuildingunitQueryID2);
   int BuildingUnits2=kbUnitQueryExecute(BuildingunitQueryID2);
  }

   //BuildingUnits for Player 3
   if (BuildingunitQueryID3 < 0)
   BuildingunitQueryID3=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID3 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID3, 3);
		kbUnitQuerySetUnitType(BuildingunitQueryID3, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID3, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID3, true);
			
   }
if (kbIsPlayerEnemy(3) && kbIsPlayerValid(3))
   {
int BuildingUnits3=kbUnitQueryExecute(BuildingunitQueryID3);
   kbUnitQueryResetResults(BuildingunitQueryID3);
  }
  
  
   //BuildingUnits for Player 4
   if (BuildingunitQueryID4 < 0)
   BuildingunitQueryID4=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID4 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID4, 4);
		kbUnitQuerySetUnitType(BuildingunitQueryID4, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID4, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID4, true);
			
   }
if (kbIsPlayerEnemy(4) && kbIsPlayerValid(4))
   {
int BuildingUnits4=kbUnitQueryExecute(BuildingunitQueryID4);
   kbUnitQueryResetResults(BuildingunitQueryID4);
  }
  
   //BuildingUnits for Player 5
   if (BuildingunitQueryID5 < 0)
   BuildingunitQueryID5=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID5 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID5, 5);
		kbUnitQuerySetUnitType(BuildingunitQueryID5, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID5, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID5, true);
			
   }
if (kbIsPlayerEnemy(5) && kbIsPlayerValid(5))
   {
int BuildingUnits5=kbUnitQueryExecute(BuildingunitQueryID5);
   kbUnitQueryResetResults(BuildingunitQueryID5);
  }
  
   //BuildingUnits for Player 6
   if (BuildingunitQueryID6 < 0)
   BuildingunitQueryID6=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID6 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID6, 6);
		kbUnitQuerySetUnitType(BuildingunitQueryID6, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID6, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID6, true);
			
   }
if (kbIsPlayerEnemy(6) && kbIsPlayerValid(6))
   {
int BuildingUnits6=kbUnitQueryExecute(BuildingunitQueryID6);
   kbUnitQueryResetResults(BuildingunitQueryID6);
  }
  
   //BuildingUnits for Player 7
   if (BuildingunitQueryID7 < 0)
   BuildingunitQueryID7=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID7 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID7, 7);
		kbUnitQuerySetUnitType(BuildingunitQueryID7, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID7, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID7, true);
			
   }
if (kbIsPlayerEnemy(7) && kbIsPlayerValid(7))
   {
int BuildingUnits7=kbUnitQueryExecute(BuildingunitQueryID7);
   kbUnitQueryResetResults(BuildingunitQueryID7);
  }
  
   //BuildingUnits for Player 8
   if (BuildingunitQueryID8 < 0)
   BuildingunitQueryID8=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID8 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID8, 8);
		kbUnitQuerySetUnitType(BuildingunitQueryID8, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID8, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID8, true);
			
   }
if (kbIsPlayerEnemy(8) && kbIsPlayerValid(8))
   {
int BuildingUnits8=kbUnitQueryExecute(BuildingunitQueryID8);
   kbUnitQueryResetResults(BuildingunitQueryID8);
  }
  
   //BuildingUnits for Player 9
   if (BuildingunitQueryID9 < 0)
   BuildingunitQueryID9=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID9 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID9, 9);
		kbUnitQuerySetUnitType(BuildingunitQueryID9, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID9, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID9, true);
			
   }
if (kbIsPlayerEnemy(9) && kbIsPlayerValid(9))
   {
int BuildingUnits9=kbUnitQueryExecute(BuildingunitQueryID9);
   kbUnitQueryResetResults(BuildingunitQueryID9);
  }
  
   //BuildingUnits for Player 10
   if (BuildingunitQueryID10 < 0)
   BuildingunitQueryID10=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID10 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID10, 10);
		kbUnitQuerySetUnitType(BuildingunitQueryID10, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID10, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID10, true);
			
   }
if (kbIsPlayerEnemy(10) && kbIsPlayerValid(10))
   {
int BuildingUnits10=kbUnitQueryExecute(BuildingunitQueryID10);
   kbUnitQueryResetResults(BuildingunitQueryID10);
  }
  
   //BuildingUnits for Player 11
   if (BuildingunitQueryID11 < 0)
   BuildingunitQueryID11=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID11 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID11, 11);
		kbUnitQuerySetUnitType(BuildingunitQueryID11, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID11, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID11, true);
			
   }
if (kbIsPlayerEnemy(11) && kbIsPlayerValid(11))
   {
int BuildingUnits11=kbUnitQueryExecute(BuildingunitQueryID11);
   kbUnitQueryResetResults(BuildingunitQueryID11);
  }
  
   //BuildingUnits for Player 12
   if (BuildingunitQueryID12 < 0)
   BuildingunitQueryID12=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (BuildingunitQueryID12 != -1)
   {
		kbUnitQuerySetPlayerID(BuildingunitQueryID12, 12);
		kbUnitQuerySetUnitType(BuildingunitQueryID12, cUnitTypeBuilding);
	        kbUnitQuerySetState(BuildingunitQueryID12, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(BuildingunitQueryID12, true);
			
   }
if (kbIsPlayerEnemy(12) && kbIsPlayerValid(12))
   {
int BuildingUnits12=kbUnitQueryExecute(BuildingunitQueryID12);
   kbUnitQueryResetResults(BuildingunitQueryID12);
  }
 
 
 // Now to the hate and compare system...

 Int TotalUnits = -0;
 Int TotalBuildings = -0;
 int TotalUnits1 = Units1+BuildingUnits1;
 int TotalUnits2 = Units2+BuildingUnits2;
 int TotalUnits3 = Units3+BuildingUnits3;
 int TotalUnits4 = Units4+BuildingUnits4;
 int TotalUnits5 = Units5+BuildingUnits5;

 int TotalUnits6 = Units6+BuildingUnits6;
 int TotalUnits7 = Units7+BuildingUnits7;
 int TotalUnits8 = Units8+BuildingUnits8;
 int TotalUnits9 = Units9+BuildingUnits9;
 int TotalUnits10 = Units10+BuildingUnits10;
 int TotalUnits11 = Units11+BuildingUnits11;
 int TotalUnits12 = Units12+BuildingUnits12;
 
 if (TotalUnits1 > TotalUnits2 && TotalUnits1 > TotalUnits3 && TotalUnits1 > TotalUnits4 && TotalUnits1 > TotalUnits5 && TotalUnits1 > TotalUnits6 && TotalUnits1 > TotalUnits7 && TotalUnits1 > TotalUnits8 && TotalUnits1 > TotalUnits9 && TotalUnits1 > TotalUnits10 && TotalUnits1 > TotalUnits11 && TotalUnits1 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(1);
		HateChoice = 1;
		TotalUnits = Units1;
		TotalBuildings = BuildingUnits1;
   }
	
	else if (TotalUnits2 > TotalUnits1 && TotalUnits2 > TotalUnits3 && TotalUnits2 > TotalUnits4 && TotalUnits2 > TotalUnits5 && TotalUnits2 > TotalUnits6 && TotalUnits2 > TotalUnits7 && TotalUnits2 > TotalUnits8 && TotalUnits2 > TotalUnits9 && TotalUnits2 > TotalUnits10 && TotalUnits2 > TotalUnits11 && TotalUnits2 > TotalUnits12) 
    	{
		aiSetMostHatedPlayerID(2);
		HateChoice = 2;
		TotalUnits = Units2;
		TotalBuildings = BuildingUnits2;
   }
	
	else if (TotalUnits3 > TotalUnits1 && TotalUnits3 > TotalUnits2 && TotalUnits3 > TotalUnits4 && TotalUnits3 > TotalUnits5 && TotalUnits3 > TotalUnits6 && TotalUnits3 > TotalUnits7 && TotalUnits3 > TotalUnits8 && TotalUnits3 > TotalUnits9 && TotalUnits3 > TotalUnits10 && TotalUnits3 > TotalUnits11 && TotalUnits3 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(3);
		HateChoice = 3;
		TotalUnits = Units3;
		TotalBuildings = BuildingUnits3;
   }
	
	else if (TotalUnits4 > TotalUnits1 && TotalUnits4 > TotalUnits2 && TotalUnits4 > TotalUnits3 && TotalUnits4 > TotalUnits5 && TotalUnits4 > TotalUnits6 && TotalUnits4 > TotalUnits7 && TotalUnits4 > TotalUnits8 && TotalUnits4 > TotalUnits9 && TotalUnits4 > TotalUnits10 && TotalUnits4 > TotalUnits11 && TotalUnits4 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(4);
		HateChoice = 4;
		TotalUnits = Units4;
		TotalBuildings = BuildingUnits4;
   }	
	
	else if (TotalUnits5 > TotalUnits1 && TotalUnits5 > TotalUnits2 && TotalUnits5 > TotalUnits3 && TotalUnits5 > TotalUnits4 && TotalUnits5 > TotalUnits6 && TotalUnits5 > TotalUnits7 && TotalUnits5 > TotalUnits8 && TotalUnits5 > TotalUnits9 && TotalUnits5 > TotalUnits10 && TotalUnits5 > TotalUnits11 && TotalUnits5 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(5);
		HateChoice = 5;
		TotalUnits = Units5;
		TotalBuildings = BuildingUnits5;
   }
	
	else if (TotalUnits6 > TotalUnits1 && TotalUnits6 > TotalUnits2 && TotalUnits6 > TotalUnits3 && TotalUnits6 > TotalUnits4 && TotalUnits6 > TotalUnits5 && TotalUnits6 > TotalUnits7 && TotalUnits6 > TotalUnits8 && TotalUnits6 > TotalUnits9 && TotalUnits6 > TotalUnits10 && TotalUnits6 > TotalUnits11 && TotalUnits6 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(6);
		HateChoice = 6;
		TotalUnits = Units6;
		TotalBuildings = BuildingUnits6;
   }
    
	else if (TotalUnits7 > TotalUnits1 && TotalUnits7 > TotalUnits2 && TotalUnits7 > TotalUnits3 && TotalUnits7 > TotalUnits4 && TotalUnits7 > TotalUnits5 && TotalUnits7 > TotalUnits6 && TotalUnits7 > TotalUnits8 && TotalUnits7 > TotalUnits9 && TotalUnits7 > TotalUnits10 && TotalUnits7 > TotalUnits11 && TotalUnits7 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(7);
		HateChoice = 7;
		TotalUnits = Units7;
		TotalBuildings = BuildingUnits7;
   }
    
	else if (TotalUnits8 > TotalUnits1 && TotalUnits8 > TotalUnits2 && TotalUnits8 > TotalUnits3 && TotalUnits8 > TotalUnits4 && TotalUnits8 > TotalUnits5 && TotalUnits8 > TotalUnits6 && TotalUnits8 > TotalUnits7 && TotalUnits8 > TotalUnits9 && TotalUnits8 > TotalUnits10 && TotalUnits8 > TotalUnits11 && TotalUnits8 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(8);
		HateChoice = 8;
		TotalUnits = Units8;
		TotalBuildings = BuildingUnits8;
   }
    
	else if (TotalUnits9 > TotalUnits1 && TotalUnits9 > TotalUnits2 && TotalUnits9 > TotalUnits3 && TotalUnits9 > TotalUnits4 && TotalUnits9 > TotalUnits5 && TotalUnits9 > TotalUnits6 && TotalUnits9 > TotalUnits8 && TotalUnits9 > TotalUnits8 && TotalUnits9 > TotalUnits10 && TotalUnits9 > TotalUnits11 && TotalUnits9 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(9);
		HateChoice = 9;
		TotalUnits = Units9;
		TotalBuildings = BuildingUnits9;
   }
    
	else if (TotalUnits10 > TotalUnits1 && TotalUnits10 > TotalUnits2 && TotalUnits10 > TotalUnits3 && TotalUnits10 > TotalUnits4 && TotalUnits10 > TotalUnits5 && TotalUnits10 > TotalUnits6 && TotalUnits10 > TotalUnits8 && TotalUnits10 > TotalUnits8 && TotalUnits10 > TotalUnits9 && TotalUnits10 > TotalUnits11 && TotalUnits10 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(10);
		HateChoice = 10;
		TotalUnits = Units10;
		TotalBuildings = BuildingUnits10;
   }
    
	else if (TotalUnits11 > TotalUnits1 && TotalUnits11 > TotalUnits2 && TotalUnits11 > TotalUnits3 && TotalUnits11 > TotalUnits4 && TotalUnits11 > TotalUnits5 && TotalUnits11 > TotalUnits6 && TotalUnits11 > TotalUnits8 && TotalUnits11 > TotalUnits8 && TotalUnits11 > TotalUnits9 && TotalUnits11 > TotalUnits10 && TotalUnits11 > TotalUnits12)
    	{
		aiSetMostHatedPlayerID(11);
		HateChoice = 11;
		TotalUnits = Units11;
		TotalBuildings = BuildingUnits11;
   }
    
	else if (TotalUnits12 > TotalUnits1 && TotalUnits12 > TotalUnits2 && TotalUnits12 > TotalUnits3 && TotalUnits12 > TotalUnits4 && TotalUnits12 > TotalUnits5 && TotalUnits12 > TotalUnits6 && TotalUnits12 > TotalUnits8 && TotalUnits12 > TotalUnits8 && TotalUnits12 > TotalUnits9 && TotalUnits12 > TotalUnits10 && TotalUnits12 > TotalUnits11)
    	{
		aiSetMostHatedPlayerID(12);
		HateChoice = 12;
		TotalUnits = Units12;
		TotalBuildings = BuildingUnits12;
   }
	

	aiEcho("Player: "+HateChoice+" has a total of "+TotalUnits+" units and "+TotalBuildings+" buildings that is visible to me.. MHP set!");
   xsEnableRule("LockOn");
   xsDisableSelf();
}

 //==============================================================================
// LockOn
//==============================================================================
rule LockOn
   minInterval 46
   inactive
{
int MHP = aiGetMostHatedPlayerID();
   static int MHPunitQueryID1=-1;
   static int MHPBuildingMHPunitQueryID1=-1;
   //Units for Player 1
   if (MHPunitQueryID1 < 0)
   MHPunitQueryID1=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching units
   if (MHPunitQueryID1 != -1)
   {
		kbUnitQuerySetPlayerID(MHPunitQueryID1, MHP);
		kbUnitQuerySetUnitType(MHPunitQueryID1, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(MHPunitQueryID1, cUnitStateAlive);
			kbUnitQuerySetSeeableOnly(MHPunitQueryID1,true);
			
   }
if (kbIsPlayerEnemy(MHP) && kbIsPlayerValid(MHP))
{
   kbUnitQueryResetResults(MHPunitQueryID1);
   
   int MHPUnits1=kbUnitQueryExecute(MHPunitQueryID1);
  }
   /*
       //BuildingUnits for Player 1
   if (MHPBuildingMHPunitQueryID1 < 0)
   MHPBuildingMHPunitQueryID1=kbUnitQueryCreate("My Unit Query");
   
   //Define a query to get all matching BuildingUnits
   if (MHPBuildingMHPunitQueryID1 != -1)
   {
		kbUnitQuerySetPlayerID(MHPBuildingMHPunitQueryID1, MHP);
		kbUnitQuerySetUnitType(MHPBuildingMHPunitQueryID1, cUnitTypeBuilding);
	        kbUnitQuerySetState(MHPBuildingMHPunitQueryID1, cUnitStateAlive);
			
   }
   if (kbIsPlayerEnemy(MHP) && kbIsPlayerValid(MHP))
{
   kbUnitQueryResetResults(MHPBuildingMHPunitQueryID1);
   int MHPBuildingUnits1=kbUnitQueryExecute(MHPBuildingMHPunitQueryID1);
  }
  
*/  
   int MHPTotalUnits1 = MHPUnits1;
   
   if (MHPTotalUnits1 > 30)
   aiEcho("Locking on player "+MHP+"!");
   
   if (MHPTotalUnits1 < 30)
   {
   aiEcho("Player "+MHP+" has less than 30 units or is an invalid target, I will try to find new hate target.");
   xsEnableRule("CountEnemyUnitsOnMap");
   xsDisableSelf();
   return;  
  }
  }