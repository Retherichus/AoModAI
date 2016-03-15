//==============================================================================
// ADMIRAL X
// admiralprogress.xs
// This is an extension of the default ai file: aomdefaultaiprogress.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// Handles progression.
//==============================================================================

//==============================================================================
// initProgress
//==============================================================================
void initProgress()
{
   OUTPUT("Progress Init.", TRACE);
}

//==============================================================================
// chooseMinorGod
//==============================================================================
int chooseMinorGod(int age = -1, int mythUnitPref = -1, int godPowerPref = -1)
{
   //So, I know there are only 2 choices in minor god selection.
   int minorGodA=kbTechTreeGetMinorGodChoices(0, age);
   int minorGodB=kbTechTreeGetMinorGodChoices(1, age);
   int finalChoice=-1;

   //Look at the myth units.
   if (mythUnitPref != -1)
   {   if ( cvMapSubType == NOMADMAP ||
        cvMapSubType == WATERNOMADMAP ||
        cvMapSubType == VINLANDSAGAMAP )
      int currentChoice=minorGodA;
      for (a=0; < 2)
      {
         if (a == 1)
            currentChoice=minorGodB;

         //Get the list of myth units that minorGodA gives us.
         int totalMythUnits=kbTechTreeGetMinorGodMythUnitTotal( currentChoice );
         for (i=0; < totalMythUnits)
         {
            //Get the myth protounit ID.
            int mythUnitProtoID=kbTechTreeGetMinorGodMythUnitByIndex( currentChoice, i );
         
            if (mythUnitPref == mythUnitProtoID)
            {
               finalChoice=currentChoice;
               break;
            }
         }

         //Kick out because we have made our choice.
         if (finalChoice != -1)
            break;
      }
   }

   //Look at the god power if we haven't made our finalChoice yet.
   if ((godPowerPref != -1) && (finalChoice == -1))
   {
      //Get the god power tech ids from the minor god tech.
      int godPowerTechIDA=kbTechTreeGetGPTechID(minorGodA);
      int godPowerTechIDB=kbTechTreeGetGPTechID(minorGodB);
      
      //Choose minor god.
      if (godPowerTechIDA == godPowerPref)
         finalChoice=minorGodA;
      else if (godPowerTechIDB == godPowerPref)
         finalChoice=minorGodB;
   }

   //So, no prefs were set, just pick one.
   if (finalChoice == -1)
   {
      //Choose minor god.
      if (minorGodA != -1)
         finalChoice=minorGodA;
      else if (minorGodB != -1)
         finalChoice=minorGodB;
   }

   //Return the final minor god choice. Note final Choice can still be invalid.
   return(finalChoice);
}

//==============================================================================
// progressAgeHandler
//==============================================================================
void progressAge2Handler(int age=1)
{
   OUTPUT("Progress Age "+age+".", TRACE);
   xsEnableRule("age2Progress");
   xsEnableRule("buildMonuments");
}

//==============================================================================
// progressAgeHandler
//==============================================================================
void progressAge3Handler(int age=2)
{
   OUTPUT("Progress Age "+age+".", TRACE);
   xsEnableRule("age3Progress");
   xsEnableRule("buildMonuments");
}

//==============================================================================
// progressAgeHandler
//==============================================================================
void progressAge4Handler(int age=3)
{
   OUTPUT("Progress Age "+age+".", TRACE);
   xsEnableRule("buildMonuments");
}

//==============================================================================
// RULE: unPauseAge2
//==============================================================================
rule unPauseAge2
   minInterval 91
   inactive
{
   if (gAge2ProgressionPlanID == -1)
   {
      OUTPUT("Age 2 Progression Plan id("+gAge2ProgressionPlanID+") is invalid.", FAILURE);
      xsDisableSelf();
      return;
   }

   aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, false);
   aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, 0, false);
   aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, false);
   xsDisableSelf();
}

//==============================================================================
// calcMonumentPos -- 
//==============================================================================
vector calcMonumentPos(int which=-1)
{
   vector basePos=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   vector towardCenter=kbGetMapCenter()-basePos;
   vector pos=cInvalidVector;
   float q=_atan2(xsVectorGetZ(towardCenter), xsVectorGetX(towardCenter)) - 2.0*PI/5.0;
   float whichfloat=which;
   q = q + whichfloat*2.0*PI/5.0;

   float c = _cos(q);
   float s = _sin(q);
   float x = c * 22.0;
   float z = s * 22.0;
   pos = xsVectorSetX(pos, x);
   pos = xsVectorSetZ(pos, z);
   pos = basePos+pos;
   return(pos);
}

//==============================================================================
// RULE: BuildMonuments
//==============================================================================
rule buildMonuments
   minInterval 117
   inactive
{
   if (cMyCulture != cCultureEgyptian)
   {
      xsDisableSelf();// This is an extension of the default ai file: aomdefaultaigodpowers.xs

      return;
   }

   static int lastQty = 0;

   int targetNum = -1;
   float scratch = 0.0;
   scratch = (-1.0 * cvRushBoomSlider) + 1.0;  //  0 for extreme rush, 2 for extreme boom
   scratch = (scratch * 1.5) + 0.5;      // 0.5 to 3.5
   targetNum = kbGetAge() + scratch;              // 0 for extreme rush, 3 for extreme boom, +1 in cAge2, 2 in cAge3, +3 in cAge4
   if ( kbGetAge() == cAge4 )
      targetNum = 5;
   if ( targetNum > 5 )
      targetNum = 5;
   OUTPUT("Ready to build up to "+targetNum+" monuments.", ECONINFO);

   if(cMyCiv == cCivIsis)
   {
      for(i=0;<targetNum)
      {
         vector loc=calcMonumentPos(i);
         OUTPUT("monument loc "+i+" x="+xsVectorGetX(loc)+" z="+xsVectorGetZ(loc), TEST);

         int unitTypeID=-1;
         if(i==0)
            unitTypeID=cUnitTypeMonument;
         else if(i==1)
            unitTypeID=cUnitTypeMonument2;
         else if(i==2)
            unitTypeID=cUnitTypeMonument3;
         else if(i==3)
            unitTypeID=cUnitTypeMonument4;
         else if(i==4)
            unitTypeID=cUnitTypeMonument5;

         if( (kbUnitCount(cMyID, unitTypeID, cUnitStateAliveOrBuilding) > 0) || (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, unitTypeID, true) >= 0) )
            continue;

         int monumentPlanID=aiPlanCreate("IsisBuildMonument"+i, cPlanBuild);
         if (monumentPlanID >= 0)
         {
            aiPlanSetVariableInt(monumentPlanID, cBuildPlanBuildingTypeID, 0, unitTypeID);
   
            aiPlanSetVariableVector(monumentPlanID, cBuildPlanInfluencePosition, 0, loc);
            aiPlanSetVariableFloat(monumentPlanID, cBuildPlanInfluencePositionDistance, 0, 20.0);
            aiPlanSetVariableFloat(monumentPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
            aiPlanSetVariableInt(monumentPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(loc));
            aiPlanSetVariableInt(monumentPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);

            aiPlanSetDesiredPriority(monumentPlanID, 35);
            aiPlanAddUnitType(monumentPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0),
               gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
            aiPlanSetEscrowID(monumentPlanID, cEconomyEscrowID);
            aiPlanSetBaseID(monumentPlanID, kbBaseGetMainID(cMyID));
            aiPlanSetActive(monumentPlanID);
         }
      }
   }
   else
   {
      //Create the plan to build the monuments.
      int pid=aiPlanCreate("Monuments "+kbGetAge(), cPlanProgression);
      if (pid >= 0)
      { 
         aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalUnitID, targetNum, true);
         if (lastQty <= 0)
            aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 0, cUnitTypeMonument);
         if ( (targetNum > 1) && (lastQty <= 4) )
            aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 1, cUnitTypeMonument2);
         if ( (targetNum > 2) && (lastQty <= 4) )
            aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 2, cUnitTypeMonument3);
         if ( (targetNum > 3) && (lastQty <= 4) )
            aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 3, cUnitTypeMonument4);
         if ( (targetNum > 4) && (lastQty <= 4) )
            aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 4, cUnitTypeMonument5);
         aiPlanSetVariableBool(pid, cProgressionPlanRunInParallel, 0, false);
         aiPlanSetDesiredPriority(pid, 35);
         aiPlanSetEscrowID(pid, cEconomyEscrowID);
         aiPlanSetBaseID(pid, kbBaseGetMainID(cMyID));
         aiPlanSetActive(pid);

         lastQty = targetNum;
      }
   }

   //Go away now.
   xsDisableSelf();
}

//==============================================================================
// RULE: age1Progress
//==============================================================================
rule age1Progress
   minInterval 15
   active
{
   if (gAge2MinorGod == -1)
		gAge2MinorGod=chooseMinorGod(cAge2, -1, -1);

	// And now a progression to get to age 2
   gAge2ProgressionPlanID=aiPlanCreate("Age 2", cPlanProgression);
   if ((gAge2ProgressionPlanID >= 0) && (gAge2MinorGod != -1))
   { 
      aiPlanSetVariableInt(gAge2ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge2MinorGod);
		aiPlanSetDesiredPriority(gAge2ProgressionPlanID, 100);
		aiPlanSetEscrowID(gAge2ProgressionPlanID, cEconomyEscrowID);
//      if(gForwardBaseID>=0)
//         aiPlanSetBaseID(gAge2ProgressionPlanID, gForwardBaseID);
//      else
         aiPlanSetBaseID(gAge2ProgressionPlanID, kbBaseGetMainID(cMyID));
      //Start paused!!
      aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, 0, true);
      aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, true);
      aiPlanSetActive(gAge2ProgressionPlanID);
      //Unpause after a brief amount of time.
      if ( (cvMapSubType != NOMADMAP) && (cvMapSubType != WATERNOMADMAP) && (cvMapSubType != VINLANDSAGAMAP) )
         xsEnableRule("unPauseAge2");
      //If we have a lot of resources, assume we want to go up fast.
      if (kbResourceGet(cResourceWood) >= 1000)
         xsSetRuleMinInterval("unPauseAge2", 5);
   }
   
   xsDisableSelf();
}

//==============================================================================
// RULE: age2Progress
//==============================================================================
rule age2Progress
   minInterval 15
   inactive
{
	if (gAge3MinorGod == -1)
		gAge3MinorGod=chooseMinorGod(cAge3, -1, -1);

	//And now a progression to get to age 3
   gAge3ProgressionPlanID=aiPlanCreate("Age 3", cPlanProgression);
   if ((gAge3ProgressionPlanID >= 0) && (gAge3MinorGod != -1))
   { 
      aiPlanSetVariableInt(gAge3ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge3MinorGod);
		aiPlanSetDesiredPriority(gAge3ProgressionPlanID, 100);
		aiPlanSetEscrowID(gAge3ProgressionPlanID, cEconomyEscrowID);
      aiPlanSetBaseID(gAge3ProgressionPlanID, kbBaseGetMainID(cMyID));
      aiPlanSetActive(gAge3ProgressionPlanID);
   }
   
   xsDisableSelf();
}

//==============================================================================
// RULE: age2Progress
//==============================================================================
rule age3Progress
   minInterval 15
   inactive
{
   if (gAge4MinorGod == -1)
		gAge4MinorGod=chooseMinorGod(cAge4, -1, -1);

  if (aiGetGameMode() == cGameModeDeathmatch)      // Non-DM will activate this after market is built
  {
   	// And now a progression to get to age 4
      gAge4ProgressionPlanID=aiPlanCreate("Age 4", cPlanProgression);
      if ((gAge4ProgressionPlanID >= 0) && (gAge4MinorGod != -1))
      { 
         aiPlanSetVariableInt(gAge4ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge4MinorGod);
         aiPlanSetDesiredPriority(gAge4ProgressionPlanID, 100);
		   aiPlanSetEscrowID(gAge4ProgressionPlanID, cEconomyEscrowID);
         aiPlanSetBaseID(gAge4ProgressionPlanID, kbBaseGetMainID(cMyID));
         aiPlanSetActive(gAge4ProgressionPlanID);
      }
  }
   
   xsDisableSelf();
}
