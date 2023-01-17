//==============================================================================
// AoMod AI
// AoModAIProgr.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Handles progression.
//==============================================================================

//==============================================================================
void progressAge2Handler(int age=1)
{
    xsEnableRule("age2Progress");
}

//==============================================================================
void progressAge3Handler(int age=2)
{
    xsEnableRule("age3Progress");
}

//==============================================================================
void progressAge4Handler(int age=3)
{
}

//==============================================================================
rule unPauseAge2
minInterval 180 //starts in cAge1
inactive
{
	
    if (gAge2ProgressionPlanID == -1)
    {
        xsDisableSelf();
        return;
	}
    aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, false);
    aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, 0, false);
    aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, false);
    xsDisableSelf();
}

//==============================================================================
rule unPauseAge3
minInterval 150 //starts in cAge2
inactive
{
	
    if (gAge2ProgressionPlanID == -1)
    {
        xsDisableSelf();
        return;
	}
    aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanPaused, false);
    aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanPaused, 0, false);
    aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, false);
    xsDisableSelf();
}

//==============================================================================
rule age1Progress
minInterval 10 //starts in cAge1
inactive
{
    gAge2ProgressionPlanID=aiPlanCreate("Age 2", cPlanProgression);
    if ((gAge2ProgressionPlanID >= 0) && (gAge2MinorGod != -1))
    { 
        aiPlanSetVariableInt(gAge2ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge2MinorGod);
        aiPlanSetDesiredPriority(gAge2ProgressionPlanID, 100);
        aiPlanSetEscrowID(gAge2ProgressionPlanID, cEconomyEscrowID);
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
rule age2Progress
minInterval 10 //starts in cAge2
inactive
{
    gAge3ProgressionPlanID=aiPlanCreate("Age 3", cPlanProgression);
    if ((gAge3ProgressionPlanID >= 0) && (gAge3MinorGod != -1))
    { 
        aiPlanSetVariableInt(gAge3ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge3MinorGod);
        aiPlanSetDesiredPriority(gAge3ProgressionPlanID, 100);
        aiPlanSetEscrowID(gAge3ProgressionPlanID, cEconomyEscrowID);
        aiPlanSetBaseID(gAge3ProgressionPlanID, kbBaseGetMainID(cMyID));
        aiPlanSetActive(gAge3ProgressionPlanID);		
		if (cMyCulture != cCultureEgyptian)
		{
			//Start paused!!
			aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanPaused, 0, true);
			aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, true);
			aiPlanSetActive(gAge3ProgressionPlanID);
			xsEnableRule("unPauseAge3"); // we want to delay the armory a bit!
		}
	}
	
    xsDisableSelf();
}

//==============================================================================
rule age3Progress
minInterval 10 //starts in cAge3
inactive
{
    gAge4ProgressionPlanID=aiPlanCreate("Age 4", cPlanProgression);
    if ((gAge4ProgressionPlanID >= 0) && (gAge4MinorGod != -1))
    { 
        aiPlanSetVariableInt(gAge4ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge4MinorGod);
        aiPlanSetDesiredPriority(gAge4ProgressionPlanID, 100);
        aiPlanSetEscrowID(gAge4ProgressionPlanID, cEconomyEscrowID);
        aiPlanSetBaseID(gAge4ProgressionPlanID, kbBaseGetMainID(cMyID));
        aiPlanSetActive(gAge4ProgressionPlanID);
	}
    xsDisableSelf();
}
