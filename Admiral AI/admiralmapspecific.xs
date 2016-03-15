//==============================================================================
// ADMIRAL X
// admiralmapspecific.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// Contains all map-specific stuff
// If you want the admiral to deal with your rms, you would need to add the
// following:
// 1. insert a line for your rms in preInitMap() in the appropriate block
// depending on whether you have a island map (transport map) or a water map
// (water but no transports required) or a land map where the admiral can't even
// fish.
// 2. If you have made a map that needs special treatment like vinlandsaga,
// you would need to add a line in the corresponding block for the "subtype" of
// the map. Currently supported subtypes are "King of the Hill"-style maps
// (KOTHMAP), nomad-maps (NOMADMAP), great britain and tos_nothamerica
// (WATERNOMADMAP) and vinlandsaga-style (VINLANDSAGAMAP)
//
//==============================================================================

extern int gTransportUnit=-1;

//==============================================================================
// initMapSpecific
//==============================================================================
void preInitMap()
{
   OUTPUT("Map Specific Init.", TRACE);

   int transport = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   // Decide if we have a water map.
   if ((cRandomMapName == "archipelago") ||
      (cRandomMapName == "shimo archipelago") ||
      (cRandomMapName == "river nile") ||
      (cRandomMapName == "vinlandsaga") ||
      (cRandomMapName == "alternate-vinlandsaga") ||
      (cRandomMapName == "islands") ||
      (cRandomMapName == "akislanddom") || // this doesn't make much sense of course
      (cRandomMapName == "team migration") ||
      (cRandomMapName == "artic islands") ||
      (cRandomMapName == "crimson isles") ||
      (cRandomMapName == "black sea") ||
      (cRandomMapName == "treasure island") || // we need water transports here to get to the center island, therefore island map
      (cRandomMapName == "delta du nil") ||    
      (cRandomMapName == "amazonas") ||    
      (cRandomMapName == "iceland") ||    
      (cRandomMapName == "aegean sea") ||    
      (cRandomMapName == "aegean sea 2") ||    
      (cRandomMapName == "mystere isle") ||    
      (cRandomMapName == "nomad rivers") ||
      (cRandomMapName == "shipwrecked") ||
      (cRandomMapName == "great britain") ||
      (cRandomMapName == "beach battles") ||
      (cRandomMapName == "beach battles tt") ||
      (cRandomMapName == "red sea migration") ||
      (cRandomMapName == "tos_northamerica-v1") ||    
      (cRandomMapName == "tos_northamerica") ||    
      (cRandomMapName == "tos_northamerica-v1-1") ||    
      (cRandomMapName == "vesuvius-v1" && kbUnitCount(cMyID, transport, cUnitStateAlive) > 0) ||
      (cRandomMapName == "river styx"))
   {
      // on these maps, the players are on different islands.
      // we therefore have to consider water transport
      // and we won't be able to raid
      gTransportMap = true;
      gWaterMap = true;
      xsEnableRule("fishing");
      OUTPUT("This is a transport map.", INFO);
   }
   else if ((cRandomMapName == "mediterranean") ||
      (cRandomMapName == "alternate-mediterranean") ||
      (cRandomMapName == "shimo mediterranean") ||
      (cRandomMapName == "anatolia") ||
      (cRandomMapName == "alternate-anatolia") ||
      (cRandomMapName == "scandinavia") ||
      (cRandomMapName == "dried up sea") ||
      (cRandomMapName == "tos_mediterranean-v1") ||
      (cRandomMapName == "ghost lake") ||
      (cRandomMapName == "monkey isle") ||
      (cRandomMapName == "morovia") ||
      (cRandomMapName == "midgard") ||
      (cRandomMapName == "alternate-midgard") ||
      (cRandomMapName == "stronghold-v1" && kbUnitCount(cMyID, transport, cUnitStateAlive) > 0) ||    
      (cRandomMapName == "shimo midgard") ||
      (cRandomMapName == "volcanic island") ||
      (cRandomMapName == "vesuvius-v1") ||
      (cRandomMapName == "nomad") ||
      (cRandomMapName == "rock island") ||
      (cRandomMapName == "coastal_v1-0") ||
      (cRandomMapName == "winter athina v2") ||
      (cRandomMapName == "british columbia") ||
      (cRandomMapName == "riverland") ||
      (cRandomMapName == "alternate-sea-of-worms") ||
      (cRandomMapName == "sea of worms")) 
   {
      // these maps contain water, which we can use to fish for example.
      // but all players are connected by land. This means that we are able
      // to rush/raid. We will not consider water transport on such maps. 
      gWaterMap = true;
      gTransportMap=false;
      xsEnableRule("fishing");

      OUTPUT("This is a water map.", INFO);
   }
   else if ((cRandomMapName == "alfheim") ||
      (cRandomMapName == "alternate-alfheim") ||
      (cRandomMapName == "shimo alfheim") ||
      (cRandomMapName == "vanaheim") ||
      (cRandomMapName == "manaheim") ||
      (cRandomMapName == "island chain") || // do not try to fish here
      (cRandomMapName == "savannah") ||
      (cRandomMapName == "alternate-savannah") ||
      (cRandomMapName == "farmland") ||
      (cRandomMapName == "stronghold-v1") ||
      (cRandomMapName == "shimo savannah") ||
      (cRandomMapName == "monkey valley") ||
      (cRandomMapName == "valley of kings") ||
      (cRandomMapName == "alternate-valley-of-kings") ||
      (cRandomMapName == "mythland") ||
      (cRandomMapName == "gold rush") ||
      (cRandomMapName == "highlands") ||
      (cRandomMapName == "alternate-highland") ||
      (cRandomMapName == "highlandsxp") ||
      (cRandomMapName == "iceworld") ||
      (cRandomMapName == "land nomad") ||
      (cRandomMapName == "green arabia new") ||
      (cRandomMapName == "misty mountain") ||
      (cRandomMapName == "black forest") ||
      (cRandomMapName == "dark forest") ||
      (cRandomMapName == "monticello") ||
      (cRandomMapName == "sudan") ||
      (cRandomMapName == "alpine") ||
      (cRandomMapName == "lost woods") ||
      (cRandomMapName == "daemonwood") ||
      (cRandomMapName == "mountain king") ||
      (cRandomMapName == "battle ground") ||
      (cRandomMapName == "alexandria") ||
      (cRandomMapName == "alexandriax2") ||
      (cRandomMapName == "arabia") ||
      (cRandomMapName == "acropolis") ||
      (cRandomMapName == "alternate-acropolis") ||
      (cRandomMapName == "oasis") ||
      (cRandomMapName == "alternate-oasis") ||
      (cRandomMapName == "jotunheim") ||
      (cRandomMapName == "alternate-jotunheim") ||
      (cRandomMapName == "macedonia") ||
      (cRandomMapName == "erebus") ||
      (cRandomMapName == "aral lake") ||
      (cRandomMapName == "tos_middleearth-v1") ||
      (cRandomMapName == "watering hole") ||
      (cRandomMapName == "stronghold") ||
      (cRandomMapName == "marsh") ||
      (cRandomMapName == "alternate-marsh") ||
      (cRandomMapName == "megalopolis") ||
      (cRandomMapName == "alternate-megalopolis") ||
      (cRandomMapName == "tundra") ||
      (cRandomMapName == "alternate-tundra") ||
      (cRandomMapName == "torangia") ||
      (cRandomMapName == "fire void") ||
      (cRandomMapName == "primrose path") ||
      (cRandomMapName == "norwegian forest") ||
      (cRandomMapName == "criss cross") ||
      (cRandomMapName == "mountain pass 0-5") ||
      (cRandomMapName == "rocky mountains") ||
      (cRandomMapName == "cherimoya") ||
      (cRandomMapName == "sudden death")) // imho: does'nt make much sense to fish here
   {
      gWaterMap=false;
      gTransportMap=false;
      gNumBoatsToMaintain = 0;
      xsDisableRule("findFish"); 
      xsDisableRule("fishing");
      OUTPUT("This is a land map.", INFO);
   }
   else
   // king of the hill
   // the unknown
   {
      OUTPUT("This is a unknown map.", INFO);
		xsEnableRule("findFish");
   }

   // find out what subtype the map is of
   if ( cRandomMapName == "gold rush" ||
        cRandomMapName == "king of the hill" ||
        cRandomMapName == "treasure island" )
   {
      cvMapSubType = KOTHMAP;
   }
   else if ( cRandomMapName == "shimo archipelago" ||
             cRandomMapName == "shimo alfheim" ||
             cRandomMapName == "shimo mediterranean" ||
             cRandomMapName == "shimo savannah" ||
             cRandomMapName == "shimo midgard" )
   {
      cvMapSubType = SHIMOMAP;
   }
   else if ( cRandomMapName == "vinlandsaga" ||
             cRandomMapName == "team migration" ||
             cRandomMapName == "alternate-vinlandsaga" ||
             cRandomMapName == "mystere isle" ||
             (cRandomMapName == "vesuvius-v1" &&
              kbUnitCount(cMyID, transport, cUnitStateAlive) > 0) )
   {
      cvMapSubType = VINLANDSAGAMAP;
   }
   else if ( cRandomMapName == "nomad" ||
             cRandomMapName == "nomad rivers" ||
             cRandomMapName == "land nomad")
   {
      cvMapSubType = NOMADMAP;
   }
   else if ( cRandomMapName == "tos_northamerica-v1" ||
             (cRandomMapName == "tos_northamerica") ||    
             (cRandomMapName == "tos_northamerica-v1-1") ||    
             cRandomMapName == "great britain")
   {
      cvMapSubType = WATERNOMADMAP;
   }

   //Tell the AI what kind of map we are on.
   aiSetWaterMap(gTransportMap == true);
}

//==============================================================================
// initMapSpecific()
//==============================================================================
void initMapSpecific()
{
   OUTPUT("initMapSpecific:", TRACE);

   kbSetForwardBasePosition(findForwardBasePos());

   // various map overrides
   if ( cRandomMapName == "farmland" )
   {
      int plan=aiPlanCreate("Farmland Forkboy Explore", cPlanExplore);
      if (plan >= 0)
      {
         aiPlanAddUnitType(plan, cUnitTypeForkboy, 1, 1, 1);
         aiPlanSetDesiredPriority(plan, 10);
         if ( cMyCulture == cCultureEgyptian )
            aiPlanSetVariableBool(plan, cExplorePlanDoLoops, 0, true);
         else
            aiPlanSetVariableBool(plan, cExplorePlanDoLoops, 0, false);
         aiPlanSetActive(plan, true);
         aiPlanSetEscrowID(plan, cEconomyEscrowID);
      }
   }
   else if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
   {
      aiSetMinNumberNeedForGatheringAggressvies(2);
      kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 85.0);
   }
   //Vinlandsaga.
   else if (cvMapSubType == VINLANDSAGAMAP)
   {
      //Enable the rule that looks for the mainland.
      xsEnableRule("findVinlandsagaBase");
      //Turn off auto dropsite building.
      aiSetAllowAutoDropsites(false);
      aiSetAllowBuildings(false);

      // Move the transport toward map center to find continent quickly.
      int transportID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
      vector nearCenter = kbGetMapCenter();
      nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;    // Halfway between start and center
      nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
      aiTaskUnitMove(transportID, nearCenter);
      OUTPUT("Sending transport "+transportID+" to near map center at "+nearCenter, MAPSPEC);
      xsEnableRule("vinlandsagaFailsafe");  // In case something prevents transport from reaching, turn on the explore plan.
      //Turn off fishing.
      xsDisableRule("fishing");
      //Pause the age upgrades.
      aiSetPauseAllAgeUpgrades(true);
   }
   //Nomad.
   else if (cvMapSubType == NOMADMAP)
   {
      xsEnableRule("nomadSearchMode");
   }
   //Make a scout plan to find the plenty vault/
   else if (cvMapSubType == KOTHMAP)
   {
      OUTPUT("looking for KOTH plenty Vault", MAPSPEC);
      int KOTHunitQueryID = kbUnitQueryCreate("findPlentyVault");
      kbUnitQuerySetPlayerRelation(KOTHunitQueryID, cPlayerRelationAny);
      kbUnitQuerySetUnitType(KOTHunitQueryID, cUnitTypePlentyVaultKOTH);
      kbUnitQuerySetState(KOTHunitQueryID, cUnitStateAny);
	   kbUnitQueryResetResults(KOTHunitQueryID);
	   int numberFound = kbUnitQueryExecute(KOTHunitQueryID);
      gKOTHPlentyUnitID = kbUnitQueryGetResult(KOTHunitQueryID, 0);
      kbSetForwardBasePosition(kbUnitGetPosition(gKOTHPlentyUnitID));

      xsEnableRule("findFish");
   }
   //Water Nomad (this is sorta mixture between nomad and vinlandsaga)
   else if (cvMapSubType == WATERNOMADMAP)
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
		OUTPUT("num="+num, MAPSPEC);
		for ( i=0; < num)
		{
		   OUTPUT("adding unit "+i, MAPSPEC);
	   	kbBaseAddUnit(cMyID, base, kbUnitQueryGetResult(query, i));
		}
      gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);
      OUTPUT("Initial Base="+gVinlandsagaInitialBaseID, MAPSPEC);

      int transportPUID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);

     // Move the transport toward map center to find continent quickly.
      gTransportUnit = findUnit(transportPUID);
      nearCenter = kbGetMapCenter();
      nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;    // Halfway between start and center
      nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
      aiTaskUnitMove(gTransportUnit, nearCenter);
      OUTPUT("Sending transport "+gTransportUnit+" to near map center at "+nearCenter, MAPSPEC);
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
   else if ( cvMapSubType == SHIMOMAP )
   {
      gShimoKingID = findUnit(gShimoKingUnitTypeID);
      if ( gShimoKingID >= 0 )
      {
         OUTPUT("This is a shimo map, defend our king "+kbGetUnitTypeName(gShimoKingUnitTypeID), MAPSPEC);
         // TODO: no idea so far, what we could do on such map. Sadly, we cannot garrison our king. No way from
         // script level :-(
         // create defend plan?
         // enable Rule to make king flee, if necessary!
         int myFortress=findUnit(cUnitTypeAbstractFortress);
      }
      else
         OUTPUT("Assumed Shimo map, but did not find king :-(", FAILURE);
   }
}

//==============================================================================
// findVinlandsagaBase
//==============================================================================
rule findVinlandsagaBase
   minInterval 10
   inactive
{
   OUTPUT("findVinlandsagaBase:", TRACE);

   //Save our initial base ID.
   gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);

   //Get our initial location.
   vector location=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   //Find the mainland area group.
   int mainlandGroupID=-1;
   if (cRandomMapName == "vinlandsaga" ||
		 cRandomMapName == "vesuvius-v1" ||
		 cRandomMapName == "alternate-vinlandsaga" ||
		 cRandomMapName == "great britain" ||
      (cRandomMapName == "tos_northamerica") ||    
      (cRandomMapName == "tos_northamerica-v1-1") ||    
		 cRandomMapName == "tos_northamerica-v1")
	{
      mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 3.0, kbAreaGetIDByPosition(location));
	}
   else
	{
      mainlandGroupID=kbFindAreaGroupByLocation(cAreaGroupTypeLand, 0.5, 0.5);  // Can fail if mountains at map center
//      mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 1.2, kbAreaGetIDByPosition(location));   // Instead, look for one 20% larger than start area group.
	}

   if (mainlandGroupID < 0)
      return;

   OUTPUT("findVinlandsagaBase: Found the mainland, AGID="+mainlandGroupID+".", MAPSPEC);

   // stop the transport right away
   int transportID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
   OUTPUT("Stopping transport "+transportID, MAPSPEC);
   aiTaskUnitMove(transportID, kbUnitGetPosition(transportID));

   //Create the mainland base.
   int mainlandBaseGID=createBaseGoal("Mainland Base", cGoalPlanGoalTypeMainBase,
      -1, 1, 0, -1, kbBaseGetMainID(cMyID));
   if (mainlandBaseGID >= 0)
   {
      //Set the area ID.
      aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanAreaGroupID, 0, mainlandGroupID);
      //Create the callback goal.
      int callbackGID=createCallbackGoal("Vinlandsaga Base Callback", "vinlandsagaBaseCallback",
         1, 0, -1, false);
      if (callbackGID >= 0)
         aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanDoneGoal, 0, callbackGID);
   }

   //Done.
   xsDisableSelf();
}  

//==============================================================================
// vinlandsagaFailsafe
//==============================================================================
rule vinlandsagaFailsafe
   minInterval 60
   inactive
{
	OUTPUT("vinlandsagaFailsafe:", TRACE);

   //Make a plan to explore with the initial transport.
	gVinlandsagaTransportExplorePlanID=aiPlanCreate("Vinlandsaga Transport Explore", cPlanExplore);
   OUTPUT("Transport explore plan: "+gVinlandsagaTransportExplorePlanID, MAPSPEC);
	if (gVinlandsagaTransportExplorePlanID >= 0)
	{
      aiPlanAddUnitType(gVinlandsagaTransportExplorePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 1, 1, 1);
		aiPlanSetDesiredPriority(gVinlandsagaTransportExplorePlanID, 1);
      aiPlanSetVariableBool(gVinlandsagaTransportExplorePlanID, cExplorePlanDoLoops, 0, false);
      aiPlanSetActive(gVinlandsagaTransportExplorePlanID);
      aiPlanSetEscrowID(gVinlandsagaTransportExplorePlanID);
	}
   xsDisableSelf();
}

//==============================================================================
// vindlandsagaEnableFishing
//==============================================================================
rule vinlandsagaEnableFishing
   minInterval 10
   inactive
{
   //See how many wood dropsites we have.
   static int wdQueryID=-1;
   //If we don't have a query ID, create it.
   if (wdQueryID < 0)
   {
      wdQueryID=kbUnitQueryCreate("Wood Dropsite Query");
      //If we still don't have one, bail.
      if (wdQueryID < 0)
         return;
      //Else, setup the query data.
      kbUnitQuerySetPlayerID(wdQueryID, cMyID);
      if (cMyCulture == cCultureGreek)
         kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStorehouse);
      else if (cMyCulture == cCultureEgyptian)
         kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLumberCamp);
      else if (cMyCulture == cCultureNorse)
         kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLogicalTypeLandMilitary);
      kbUnitQuerySetAreaGroupID(wdQueryID, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) );
      kbUnitQuerySetState(wdQueryID, cUnitStateAlive);
   }
   //Reset the results.
   kbUnitQueryResetResults(wdQueryID);
   //Run the query.  If we don't have anything, skip.
   if (kbUnitQueryExecute(wdQueryID) <= 0)
      return;

   if ( cvMapSubType == WATERNOMADMAP )
   {
      if ( findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < 0 )
         return;
   }

   //Enable the rule.
   xsEnableRule("fishing");
   //Unpause the age upgrades.
   aiSetPauseAllAgeUpgrades(false);
   //Unpause the pause kicker.
   xsEnableRule("unPauseAge2");
   xsSetRuleMinInterval("unPauseAge2", 15);

   //Create a simple plan to maintain X Ulfsarks (since we didn't do this as part of initNorse).
   createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, true, kbBaseGetMainID(cMyID));

   //Disable us.
   xsDisableSelf();
}  


//==============================================================================
// vinlandsagaBaseCallback
//==============================================================================
void vinlandsagaBaseCallback(int parm1=-1)
{
   OUTPUT("VinlandsagaBaseCallback:", TRACE);

   //Get our water transport type.
   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   if (transportPUID < 0)
      return;
   //Get our main base.  This needs to be different than our initial base.
   if (kbBaseGetMainID(cMyID) == gVinlandsagaInitialBaseID)
      return;

   //Kill the transport explore plan.
   aiPlanDestroy(gVinlandsagaTransportExplorePlanID);
   xsDisableRule("vinlandsagaFailsafe");
   //Kill the land scout explore.
   aiPlanDestroy(gLandExplorePlanID);
   //Create a new land based explore plan for the mainland.
	gLandExplorePlanID=aiPlanCreate("Explore_Land_VS", cPlanExplore);
   if (gLandExplorePlanID >= 0)
   {
      aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);
      aiPlanSetActive(gLandExplorePlanID);
      aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
      aiPlanSetBaseID(gLandExplorePlanID, kbBaseGetMainID(cMyID));
      //Don't loop as egyptian.
      if (cMyCulture == cCultureEgyptian)
         aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
      aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);
   }

   //Get our start area ID.
   int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
   //Get our goal area ID.
   int goalAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

   goalAreaID = verifyVinlandsagaBase( goalAreaID );  // Make sure it borders water,or find one that does.

	int planID=-1;
   if ( cvMapSubType == WATERNOMADMAP )
   {
      int num = kbUnitCount(cMyID, cUnitTypeUnit, cUnitStateAny);
      planID=createTransportPlan("All Units Transport", startAreaID, goalAreaID,
                                    false, transportPUID, 100, gVinlandsagaInitialBaseID);
		if ( planID >= 0 )
		{
		   aiPlanSetVariableBool(planID, cTransportPlanReturnWhenDone, 0, false);
			aiPlanAddUnitType(planID, cUnitTypeUnit, num, num, num);
			aiPlanAddUnitType(planID, cUnitTypeHero, 1, 1, 1);
			aiPlanSetActive(planID);
		}

      //Enable the rule that looks for a settlement.
		xsEnableRule("nomadSearchMode");
		xsEnableRule("transportAllUnits");
   }
	else
	{
      //Create the scout/villager xport plan.  If it works, add the unit type(s).
      planID=createTransportPlan("Villager Transport", startAreaID, goalAreaID,
         true, transportPUID, 100, gVinlandsagaInitialBaseID);
      if (planID >= 0)
      {
         aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 1, 5, 5);
         if (cMyCulture == cCultureAtlantean)
                aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 1, 3, 3);
         aiPlanAddUnitType(planID, cUnitTypeLogicalTypeLandMilitary, 0, 1, 1);
         aiPlanAddUnitType(planID, gLandScout, 1, 1, 1);
         if (cMyCulture == cCultureNorse)
            aiPlanAddUnitType(planID, cUnitTypeOxCart, 0, 1, 4);
      }
      OUTPUT("Transport plan ID is "+planID, MAPSPEC);
	}

   //change the farming baseID
   gFarmBaseID=kbBaseGetMainID(cMyID);

   //Allow auto dropsites again.
   aiSetAllowAutoDropsites(true);
   aiSetAllowBuildings(true);

   xsDisableRule("setEarlyEcon");
   xsEnableRule("econForecastAge1Mid");

   //Enable the rule that will eventually enable fishing and other stuff.
   xsEnableRule("vinlandsagaEnableFishing");
}

//==============================================================================
// transportAllUnits
//==============================================================================
rule transportAllUnits
   inactive
   minInterval 5
{
   int num = findNumberOfUnitsInBase(cMyID, gVinlandsagaInitialBaseID);
	if ( num <= 0 )
	{
	   xsDisableSelf();
		return;
	}

   //Get our water transport type.
   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   if (transportPUID < 0)
      return;
	
   //Get our start area ID.
   int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
   //Get our goal area ID.
   int goalAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

   if (aiPlanGetIDByTypeAndVariableType(cPlanTransport) >= 0)
      return;

   goalAreaID = verifyVinlandsagaBase( goalAreaID );  // Make sure it borders water,or find one that does.

	int planID=-1;
   planID=createTransportPlan("All Units Transport", startAreaID, goalAreaID,
                                 false, transportPUID, 100, gVinlandsagaInitialBaseID);
	if ( planID >= 0 )
	{
	   aiPlanSetVariableBool(planID, cTransportPlanReturnWhenDone, 0, false);
		aiPlanAddUnitType(planID, cUnitTypeUnit, 1, num, num);
		aiPlanAddUnitType(planID, cUnitTypeHero, 1, 1, 1);
		aiPlanSetActive(planID);
	}
}

//==============================================================================
// nomadBuildSettlementCallBack
//==============================================================================

//==============================================================================
// RULE nomadSearchMode
//==============================================================================
rule nomadSearchMode
inactive
minInterval 1
{
      //Enable the rule that looks for a settlement.
/*
      int nomadSettlementGoalID=createBuildSettlementGoal("BuildNomadSettlement", 0, -1, -1, 1,
         kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0), true, 100);
      if (nomadSettlementGoalID != -1)
      {
         //Create the callback goal.
         int nomadCallbackGID=createCallbackGoal("Nomad BuildSettlement Callback", "nomadBuildSettlementCallBack", 1, 0, -1, false);
         if (nomadCallbackGID >= 0)
            aiPlanSetVariableInt(nomadSettlementGoalID, cGoalPlanDoneGoal, 0, nomadCallbackGID);
      }
*/
      //Make plans to explore with the initial villagers and goats.
      OUTPUT("Making nomad explore plans.", MAPSPEC);
	   gNomadExplorePlanID1=aiPlanCreate("Nomad Explore 1", cPlanExplore);
	   if (gNomadExplorePlanID1 >= 0)
	   {
         aiPlanAddUnitType(gNomadExplorePlanID1, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
		   aiPlanSetDesiredPriority(gNomadExplorePlanID1, 90);
         aiPlanSetVariableBool(gNomadExplorePlanID1, cExplorePlanDoLoops, 0, false);
         aiPlanSetActive(gNomadExplorePlanID1);
         aiPlanSetEscrowID(gNomadExplorePlanID1);
	   }
	   gNomadExplorePlanID2=aiPlanCreate("Nomad Explore 2", cPlanExplore);
	   if (gNomadExplorePlanID2 >= 0)
	   {
         aiPlanAddUnitType(gNomadExplorePlanID2, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
		   aiPlanSetDesiredPriority(gNomadExplorePlanID2, 90);
         aiPlanSetVariableBool(gNomadExplorePlanID2, cExplorePlanDoLoops, 0, false);
         aiPlanSetActive(gNomadExplorePlanID2);
         aiPlanSetEscrowID(gNomadExplorePlanID2);
	   }
      gNomadExplorePlanID3=aiPlanCreate("Nomad Explore 3", cPlanExplore);
	   if (gNomadExplorePlanID3 >= 0)
	   {
         aiPlanAddUnitType(gNomadExplorePlanID3, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 2, 2);   // Grab last Egyptian
		   aiPlanSetDesiredPriority(gNomadExplorePlanID3, 90);
         aiPlanSetVariableBool(gNomadExplorePlanID3, cExplorePlanDoLoops, 0, false);
         aiPlanSetActive(gNomadExplorePlanID3);
         aiPlanSetEscrowID(gNomadExplorePlanID3);
	   }      

      //Turn off fishing.
      xsDisableRule("fishing");
      //Turn off buildhouse.
      xsDisableRule("buildHouse");
      //Pause the age upgrades.
      //aiSetPauseAllAgeUpgrades(true);

      xsDisableRule("earlySettlementTracker");  // Normal settlement-building rule

      xsEnableRule("nomadBuildMode");
      xsDisableSelf();
      OUTPUT("Enabling nomadBuildMode", MAPSPEC);

}

//==============================================================================
// RULE nomadBuildMode
//==============================================================================
rule nomadBuildMode        // Go to build mode when a suitable settlement is found
inactive
minInterval 1
{
   int count = -1;   // How many settlements found?

   static int settlementQuery = -1;    // All gaia settlements
   if (settlementQuery < 0)
   {
      settlementQuery = kbUnitQueryCreate("Nomad Settlement");
      kbUnitQuerySetPlayerID(settlementQuery, 0);
      kbUnitQuerySetUnitType(settlementQuery, cUnitTypeAbstractSettlement);
   }

   static int builderQuery = -1;      // All builders within 20 meters of a gaia settlement
   if (builderQuery < 0)
   {
      builderQuery = kbUnitQueryCreate("Nomad Builder");
      kbUnitQuerySetPlayerID(builderQuery, cMyID);
      kbUnitQuerySetUnitType(builderQuery, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
      kbUnitQuerySetState(builderQuery, cUnitStateAlive);
      kbUnitQuerySetMaximumDistance(builderQuery, 30.0);
      kbUnitQuerySetAscendingSort(builderQuery, true);
   }  

   kbUnitQueryResetResults(settlementQuery);
   count = kbUnitQueryExecute(settlementQuery);
   if (count < 1)
      return;     // No settlements seen, give up

   // Settlements seen, check if you have a builder close by
   OUTPUT("Found "+count+" settlements.", MAPSPEC);
   int i = -1;
   int settlement = -1;
   int foundSettlement = -1;

   for (i=0; < count)
   {
      settlement = kbUnitQueryGetResult(settlementQuery, i);
      OUTPUT("    Checking settlement "+settlement+" at "+kbUnitGetPosition(settlement), MAPSPEC);
      kbUnitQuerySetPosition(builderQuery, kbUnitGetPosition(settlement));
      kbUnitQueryResetResults(builderQuery);
      if ( kbUnitQueryExecute(builderQuery) > 0)   // Builder nearby
      {
         foundSettlement = settlement;
         OUTPUT("        Builder found, we'll use "+settlement, MAPSPEC);
         break;
      }
      OUTPUT("        No builders nearby.", MAPSPEC);
   }
   
   // If we found a usable settlement, build on it.  Otherwise, keep this rule active
   if (foundSettlement < 0)
      return;
   
   // We have one, let's use it and monitor for completion

   /*
   gNomadSettlementBuildPlanID=aiPlanCreate(name, cPlanGoal);
   if (gNomadSettlementBuildPlanID < 0)
      return(-1);



   //Goal Type.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuildSettlement);
   //Base ID.
   aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
   //Auto update.
   aiPlanSetVariableBool(gNomadSettlementBuildPlanID, cGoalPlanAutoUpdateState, 0, true);
   //Building Type ID.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanBuildingTypeID, 0, cUnitTypeAbstractSettlement);
   //Building Search ID.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanBuildingSearchID, 0, cUnitTypeAbstractSettlement);
   //Set the builder parms.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMinUnitNumber, 0, 1);
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMaxUnitNumber, 0, 3);
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanUnitTypeID, 0, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
   
   //Priority.
   aiPlanSetDesiredPriority(gNomadSettlementBuildPlanID, 100);
   //Ages.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMinAge, 0, 0);
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMaxAge, 0, -1);
   //Repeat.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanRepeat, 0, -1);
   */
   OUTPUT("Making main base.", MAPSPEC);
   int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), kbUnitGetPosition(settlement), 75.0);
   if (newBaseID > -1)
   {
      //Figure out the front vector.
      vector baseFront=xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(settlement));
      kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
      OUTPUT("Setting front vector to "+baseFront, MAPSPEC);
      //Military gather point.
      vector militaryGatherPoint=kbUnitGetPosition(settlement)+baseFront*40.0;
      kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
      //Set the other flags.
      kbBaseSetMilitary(cMyID, newBaseID, true);
      kbBaseSetEconomy(cMyID, newBaseID, true);
      //Set the resource distance limit.
      kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
      //Add the settlement to the base.
//      kbBaseAddUnit(cMyID, newBaseID, settlementID);
      kbBaseSetSettlement(cMyID, newBaseID, true);
      //Set the main-ness of the base.
      kbBaseSetMain(cMyID, newBaseID, true);
   }
//EnableRule("buildSettlements");

   OUTPUT("Main base is "+newBaseID+" "+kbBaseGetMainID(cMyID), MAPSPEC);

   OUTPUT("Creating simple build plan", MAPSPEC);

	gNomadSettlementBuildPlanID=aiPlanCreate("Nomad settlement build", cPlanBuild);
   if (gNomadSettlementBuildPlanID < 0)
      return;
   //Puid.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
   //Priority.
   aiPlanSetDesiredPriority(gNomadSettlementBuildPlanID, 100);
   //Mil vs. Econ.
   aiPlanSetMilitary(gNomadSettlementBuildPlanID, false);
   aiPlanSetEconomy(gNomadSettlementBuildPlanID, true);
   //Escrow.
   aiPlanSetEscrowID(gNomadSettlementBuildPlanID, cEconomyEscrowID);
   //Builders.
	aiPlanAddUnitType(gNomadSettlementBuildPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 4, 4, 4);
   //Base ID.
   aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
   aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanCenterPosition, 0, kbUnitGetPosition(foundSettlement));
   aiPlanSetVariableFloat(gNomadSettlementBuildPlanID, cBuildPlanCenterPositionDistance, 0, 2.0);
//   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanFoundationID, 0, foundSettlement);
   aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanSettlementPlacementPoint, 0, kbUnitGetPosition(foundSettlement));
   //Go.
   aiPlanSetActive(gNomadSettlementBuildPlanID);


   OUTPUT("Killing explore plans.", MAPSPEC);
   aiPlanDestroy(gNomadExplorePlanID1);
   aiPlanDestroy(gNomadExplorePlanID2);
   aiPlanDestroy(gNomadExplorePlanID3);

   xsEnableRule("nomadMonitor");
   xsDisableSelf();
   OUTPUT("Activating nomad monitor rule", MAPSPEC);
}

//==============================================================================
// RULE nomadMonitor
//==============================================================================
rule nomadMonitor    // Watch the build goal.  When a settlement is up, turn on normal function.  If goal fails, restart.
inactive
minInterval 1
{
   if ( (aiPlanGetState(gNomadSettlementBuildPlanID) >= 0) && (aiPlanGetState(gNomadSettlementBuildPlanID) != cPlanStateDone) )
      return;     // Plan exists, is not finished

   // plan is done or died.  Check if we have a settlement
   if (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0) // AliveOrBuilding in case state isn't updated instantly
   {  // We have a settlement, go normal
      OUTPUT("Settlement is finished, normal start.", MAPSPEC);
      xsDisableSelf();
      xsEnableRule("earlySettlementTracker");
      //Turn on fishing.
		if ( cvMapSubType == WATERNOMADMAP )
         xsEnableRule("fishing");      
      //Turn off buildhouse.
      xsEnableRule("buildHouse");

      int tc = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
      if ( tc >= 0)   
      {

         // Set main base
         int oldMainBase = kbBaseGetMainID(cMyID);
         OUTPUT("Old main base was "+oldMainBase, MAPSPEC);
            OUTPUT("Killing early gather plans.", MAPSPEC);
            aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, oldMainBase);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, oldMainBase);
            aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, oldMainBase);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, oldMainBase);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, oldMainBase);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, oldMainBase);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, oldMainBase);
            aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, -1);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, -1);
            aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, -1);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, -1);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, -1);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, -1);
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, -1);
            aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, -1);
            aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));

         if ( kbUnitGetBaseID(tc) != oldMainBase )
         {
            kbBaseDestroy(cMyID, oldMainBase);
            kbBaseSetMain(cMyID, kbUnitGetBaseID(tc),true);
         }
         OUTPUT("TC is in base "+kbUnitGetBaseID(tc), MAPSPEC);
         OUTPUT("New main base is "+kbBaseGetMainID(cMyID), MAPSPEC);
         vector front = cInvalidVector;
         front = xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(tc));
         kbBaseSetFrontVector(cMyID, kbBaseGetMainID(cMyID), front);
         OUTPUT("Front vector is "+front, MAPSPEC);
         gFarmBaseID = kbBaseGetMainID(cMyID);
         // Fix herdable plans
	      aiPlanDestroy(gHerdPlanID);
         gHerdPlanID=aiPlanCreate("GatherHerdable Plan Nomad", cPlanHerd);
         if (gHerdPlanID >= 0)
         {
            aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
            aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
            aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingID, 0, tc);
            aiPlanSetActive(gHerdPlanID);
         }
         aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));
         updateFoodBreakdown();

      }




      // Fix god power plan for age 1
      aiPlanSetBaseID(gAge1GodPowerPlanID, kbBaseGetMainID(cMyID));



      // force the temple soon
      createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
      //Unpause the age upgrades.
      aiSetPauseAllAgeUpgrades(false);
      //Unpause the pause kicker.
      xsEnableRule("unPauseAge2");
      xsSetRuleMinInterval("unPauseAge2", 15);

   }
   else
   {  // No settlement, restart chain
      OUTPUT("No settlement exists, restart nomad chain.", MAPSPEC);
      xsEnableRule("nomadSearchMode");
      xsDisableSelf();
   }
}

//==============================================================================
// RULE getKingOfTheHillVault
//==============================================================================
rule getKingOfTheHillVault
   minInterval 17
   runImmediately
   active
{
   OUTPUT("getKingOfTheHillVault:", TRACE);

   //If we're not on KOTH, go away.
   if ((cRandomMapName != "king of the hill") || (gKOTHPlentyUnitID == -1))
   {
      xsDisableSelf();
      return;
   }

   //If we already have a attack goals, then quit.
   if (aiPlanGetIDByTypeAndVariableType(cPlanGoal, cGoalPlanGoalType, cGoalPlanGoalTypeAttack, true) >= 0)
      return;
   //If we already have a scout plan for this, bail.
   if (aiPlanGetIDByTypeAndVariableType(cPlanExplore, cExplorePlanNumberOfLoops, -1, true) >= 0)
      return;
   
   //Create an explore plan to go there.
   vector unitLocation=kbUnitGetPosition(gKOTHPlentyUnitID);
   int exploreID=aiPlanCreate("getPlenty", cPlanExplore);
	if (exploreID >= 0)
	{
      aiPlanAddUnitType(exploreID, cUnitTypeLogicalTypeLandMilitary, 5, 5, 5);
      aiPlanAddWaypoint(exploreID, unitLocation);
      aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
      aiPlanSetVariableBool(exploreID, cExplorePlanQuitWhenPointIsVisible, 0, true);
      aiPlanSetVariableBool(exploreID, cExplorePlanAvoidingAttackedAreas, 0, false);
      aiPlanSetVariableInt(exploreID, cExplorePlanNumberOfLoops, 0, -1);
      aiPlanSetRequiresAllNeedUnits(exploreID, true);
      aiPlanSetVariableVector(exploreID, cExplorePlanQuitWhenPointIsVisiblePt, 0, unitLocation);
		aiPlanSetDesiredPriority(exploreID, 100);
      aiPlanSetActive(exploreID);
	}
}

//==============================================================================
// mapPreventsRush --
// TODO: this are not all maps that prevent rushes.
//==============================================================================
bool mapPreventsRush()
{
   OUTPUT("mapPreventsRush:", TRACE);
   if ((cRandomMapName == "vinlandsaga") ||
      (cRandomMapName == "river nile") ||
      (cRandomMapName == "alternate-vinlandsaga") ||
      (cRandomMapName == "amazonas") ||
      (cRandomMapName == "team migration") ||
      (cRandomMapName == "archipelago") ||
      (cRandomMapName == "black sea"))
      return(true);
   
//   return(gTransportMap);
   return(false);
}

//==============================================================================
// mapPreventsWalls --
// some maps do not allow walls or it doesn't make sense to build walls there
//==============================================================================
bool mapPreventsWalls()
{
   OUTPUT("mapPreventsWalls:", TRACE);
   if ( cRandomMapName == "acropolis" ||
        cRandomMapName == "alternate-acropolis" ||
        cRandomMapName == "stronghold-v1" ||
        cRandomMapName == "torangia" ||
        cRandomMapName == "amazonas" ||
        cRandomMapName == "fire void" ||
        cRandomMapName == "the void" ||
        cRandomMapName == "daemonwood" ||
        cRandomMapName == "black forest" ||
        cRandomMapName == "akIslandDom" )
   {
      return(true);
   }

   // do not allow walls on island maps.
   return( gTransportMap );
}

/*
//==============================================================================
// mapAllowsWonderAtStart -- 
// some maps do not allow to create a building placement for a wonder at
// start -> @seealso adimral.xs::init
// these are mostly nomad maps, where we will determine our main base later
// in game...The main base at start is just temporary.
//==============================================================================
bool mapAllowsWonderAtStart()
{
   OUTPUT("mapAllowsWonderAtStart:", TRACE);
   if ( cvMapSubType == NOMADMAP ||
        cvMapSubType == WATERNOMADMAP ||
        cvMapSubType == VINLANDSAGAMAP )
   {
      return(false);
   }

   // these maps don't allow a wonder at all, because it won't help us win here!
   if ( cvMapSubType == SHIMOMAP || cvMapSubType == KOTHMAP )
      return(false);

   return(true);
}

//==============================================================================
// mapAllowsSiegeShips --
// some island maps are good for siege ships, most are not.
//==============================================================================
bool mapAllowsSiegeShips()
{
   OUTPUT("mapAllowsSiegeShips:", TRACE);
   return(cRandomMapName == "crimson isles" ||
			 cRandomMapName == "great britain" ||
			 cRandomMapName == "shipwrecked");
}
*/

//==============================================================================
// mapPreventsForwardBase --
// Some maps prevent building a forward base.
// This are mostly maps where it is impossible to build in the center.
// Some maps are asymmetric (meaning that the distance between us and the center
// is different from the distance between the enemy and the center) and therefore
// its difficult to guess where the enemy is.
// Don't build forward bases on such maps as long as our enemy-finding
// doesn't get more intelligent.
// Never build forward base on island maps.
// TODO: is this still true? Test this.
//==============================================================================
bool mapPreventsForwardBase()
{
   OUTPUT("mapPreventsForwardBase:", TRACE);

   if ( cRandomMapName == "aral lake" ||
        cRandomMapName == "iceworld" ||
        cRandomMapName == "morovia" ||
        cRandomMapName == "ghost lake" ||
        cRandomMapName == "coastal_v1-0" ||
        cRandomMapName == "torangia" ||
        cRandomMapName == "fire void" ||
        cRandomMapName == "the void" ||
        cRandomMapName == "daemonwood" ||
        cRandomMapName == "black forest" ||
        cRandomMapName == "oasis" ||
        cRandomMapName == "alternate-mediterranean" ||
        cRandomMapName == "mediterranean" )
      return(true);

   return( gTransportMap );
}

bool mapPreventsHousesAtTowers()
{
   OUTPUT("mapPreventsHousesAtTowers:", TRACE);
   if ( cRandomMapName == "amazonas" ||
        cRandomMapName == "acropolis" ||
        cRandomMapName == "alternate-acropolis" )
      return(true);

   return(false);
}

