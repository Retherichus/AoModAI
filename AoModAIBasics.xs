//==============================================================================
// AoMod AI
// AoModAIBasics.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Basic functions and definitions
//==============================================================================

//==============================================================================
// Set this to true to let the AoMod ai explore other islands. 
// This is a potential reason for the crashes
// Set this to false to disallow exploration of other islands. This may avoid
// the crashes but also means less strength of AoMod ai...
// This is again nothing but a wild guess. If the game doesn't crash if this
// variable is set to false, I will have to rework the exploration part...
extern bool cvDoExploreOtherIslands = false;

// Behavior modifiers - "control variable" sliders that range from -1 to +1 to adjust AI personalities.  Set them in setParameters().
extern float cvRushBoomSlider = 0.0;         // +1 is extreme rush, -1 is extreme boom.  Rush will age up fast and light
                                             // with few upgrades, and will start a military sooner.  Booming will hit
                                             // age 2 earlier, but will buy upgrades sooner, make more villagers, and 
                                             // will put a priority on additional settlements...but starts a military
                                             // much later.
extern float cvMilitaryEconSlider = 0.0;     // Works in conjunction with Rush/Boom.  Settings near 1 will put a huge
                                             // emphasis on military pop and resources, at the expense of the economy.
                                             // Setting it near -1 will put almost everything into the economy.  This
                                             // slider loses most of its effect in 4th age once all settlements are claimed
                                             // Military/Econ at 1.0, Rush/Boom at 1.0:  Quick jump to age 2, rush with almost no vill production.
                                             // Military 1, Rush/Boom -1:  Late to age 2, normal to age 3 with small military, grab 2 more settlements, then all military
                                             // Military/Econ -1, Rush/Boom +1:  Jump quickly to age 2, then jump quickly to age 3, delay upgrades and military.
                                             // Military/Econ -1, Rush/Boom -1:  Almost no military until all settlements are claimed.  Extremely risky boom.
extern float cvOffenseDefenseSlider = 0.0;   // Set high (+1+, causes all military investment in units.  Set low (-1), most military investment in towers and walls.
extern float cvSliderNoise = 0.3;            // The amount of random variance in slider variables.  Set it to 0.0 to have the values locked.  0.3 allows some variability.
                                             // Must be non-negative.  Resultant slider values will be clipped to range -1 through +1.

// Minor god choices.  These MUST be made in setParameters and not changed after that.  
// -1 means the AI chooses as it normally would.  List of god names follows.
extern int  cvAge2GodChoice = -1;
// cTechAge2Athena, cTechAge2Ares, cTechAge2Hermes, cTechAge2Anubis, cTechAge2Bast,
// cTechAge2Ptah, cTechAge2Forseti, cTechAge2Heimdall, cTechAge2Freyja,
// cTechAge2Okeanus, cTechAge2Prometheus, cTechAge2Leto
extern int  cvAge3GodChoice = -1;
// cTechAge3Apollo, cTechAge3Aphrodite, cTechAge3Hathor, cTechAge3Nephthys, cTechAge3Sekhmet
// cTechAge3Skadi, cTechAge3Bragi, cTechAge3Njord, cTechAge3Dionysos
// cTechAge3Hyperion, cTechAge3Rheia, cTechAge3Theia
extern int  cvAge4GodChoice = -1;
// cTechAge4Hera, cTechAge4Artemis, cTechAge4Hephaestus, cTechAge4Thoth
// cTechAge4Osiris, cTechAge4Horus, cTechAge4Hel, cTechAge4Baldr, cTechAge4Tyr,
// cTechAge4Helios, cTechAge4Hekate, cTechAge4Atlas

// DelayStart:  Setting this true will suspend ai initialization.  To resume, call setDelayStart(false).
extern bool    cvDelayStart = false;


// DoAutoSaves:  Setting this true will cause the AI to do an auto-save every 3 minutes.  Setting it false
// will eliminate auto saves.
// Use only in setParamters()
extern bool cvDoAutoSaves = true;


// MaxAge:  Sets the age limit for this player.  Be careful to use cAge1...cAge4 constants, like cvMaxAge = cAge2 to 
// limit the player to age 2.  The actual age numbers used by the code are 0...3, so cAge1...cAge4 is much clearer.
// Set initially in setParameters(), then update dynamically with setMaxAge() if needed.
extern int     cvMaxAge = cAge5;


// MaxGathererPop:  Sets the maximum number of gatherers, but doesn't include fishing boats or trade carts (or dwarves?).
// Set initially in setParameters(), can be changed dynamically with setMaxGathererPop().
extern int     cvMaxGathererPop = -1;    // -1 turns it off, meaning the scripts can do what they want.  0 means no gatherers.

// MaxMilPop:  The maximum number of military UNITS (not pop slots) that the player can create.  
// Set initially in setParameters(), can be changed dynamically with setMaxMilPop().
extern int     cvMaxMilPop = -1;         // -1 turns it off, meaning the scripts can do what they want.  0 means no military.

// MaxSettlements:  The maximum number of settlements this AI player may claim.
// Set initially in setParameters(), can be changed dynamically with setMaxSettlements().
extern int     cvMaxSettlements = 100; // Way high, no limit really.

// MaxTradePop:  Tells the AI how many trade units to make.  May be changed via setMaxTradePop().  If set to -1, the AI decides on its own.
extern int     cvMaxTradePop = -1;

// OkToAttack:  Setting this false will prevent the AI from using its military units outside of its bases.
// Setting it true allows the AI to attack at will.  This variable can be changed during the course of the game
// by using setOkToAttack().
extern bool    cvOkToAttack = true;

// OkToBuild:  Gives the AI permission to build buildings.  Setting it false will prevent any building, including
// dropsites and houses...so only use it in scenarios where you will be providing the needed buildings.
// Set it initially in setParameters(), change it later if needed via setOkToBuild().
extern bool    cvOkToBuild = true;

// OkToBuildTowers:  Gives the AI permission to build Towers if it wants to.  Set it initially in setParamaters, change
// it later if needed using setOkToBuildTowers(int quantity), where quantity is the number of towers to make.
extern bool    cvOkToBuildTowers = true;

// OkToBuildWalls:  Gives the AI permission to build walls if it wants to.  Set it initially in setParamaters, change
// it later if needed using setOkToBuildWalls().  Setting it true later will FORCE wall-building...the AI decision on its own can 
// only happen at game start.
extern bool    cvOkToBuildWalls = true;


// OkToChat:  Setting this false will suppress the AI chats/taunts that it likes to send on age-up and attack events.
// Set initially in setParameters().  Can be changed dynamically with setOkToChat().
extern bool    cvOkToChat = true;


// OkToGatherRelics:  Setting this false will prevent the AI from gathering relics.
extern bool    cvOkToGatherRelics = true;

// OkToResign:  Setting this true will allow the AI to resign when it feels bad.  Setting it false will force it to play to the end.
extern bool    cvOkToResign = true;

// God power activation switches.  Set in setParameters(), can be modified later via cvOkToUseAge*GodPower() calls.
extern bool    cvOkToUseAge1GodPower = true;
extern bool    cvOkToUseAge2GodPower = true;
extern bool    cvOkToUseAge3GodPower = true;
extern bool    cvOkToUseAge4GodPower = true;

// OkToTrainArmy:  Not implemented, use cvMaxMilPop = 0 instead.

// OkToTrainGatherers:  Not implemented, see cvMaxGathererPop = 0 instead.

// PlayerToAttack:  -1 means not defined.  Number > 0 means attack that player number, overrides mostHatedPlayer.
extern int     cvPlayerToAttack = -1;     

// Military unit controls.  Read the entire comment block below the variable declarations, these must be used carefully.
extern int     cvPrimaryMilitaryUnit = -1;
extern int     cvSecondaryMilitaryUnit = -1;
extern int     cvTertiaryMilitaryUnit = -1;
extern int     cvNumberMilitaryUnitTypes = -1;
/*
   These variables can be used to tell the AI which military units to make, and how many types to make.  
   They should be set in setParameters if you want them to take effect immediately.  
   Later, they may be changed via the following calls:
      setMilitaryUnitPrefs(primary, secondary, tertiary), and setNumberMilitaryUnitTypes().
   Set each choice to -1 to turn it off, which then will allow the AI to make its normal choices.
   Set the numberMilitaryUnits to -1 (or use no parameter) to return the AI to its default.
   Example:
      // In setParameters(), start with an archer/cav army.
      cvNumberMilitaryUnitTypes = 2;
      cvPrimaryMilitaryUnit = cUnitTypeToxotes;
      cvSecondaryMilitaryUnit = cUnitTypeHippikon;

      // Then, in a rule that fires in age 3, and archer/counterCav/siege army
      setNumberMilitaryUnitTypes(3);
      setMilitaryUnitPrefs(cUnitTypeHoplite, cUnitTypeProdromos, cUnitTypePetrobolos);

      // Use an age 4 rule to make a hippikon/siege army
      setNumberMilitaryUnits(2);
      setMilitaryUnitPrefs(cUnitTypeHippikon, cUnitTypePetrobolos);  // No tertiary required, all parameters are options.

      // Finally, turn it off and let the AI choose:
      setNumberMilitaryUnits();  // No parameter means AI gets its choice.  Could also send -1 if you prefer.
      setMilitaryUnitPrefs();    // No parameter means clear them all.

  These functions work by massively distorting the unit picker's inherent preferences, so it's very important to turn
  them off when you're done.

  Primary must be used if secondary or tertiary are used.  For example, setting primary and secondary to -1 (off) and
  setting tertiary to cUnitTypeToxotes will have the effect of choosing nothing.  There is no way to tell 
  the AI to pick its own primary and secondary but override the tertiary.  You can set numberMiltiaryUnitTypes to 3 and only define 
  the primary, leaving it to pick the second and third.

  Finally, there is a side effect.  Hades may prefer archers initially.  If you tell him to make archers, he will.  When you tell him
  to later make up his own mind, his preference for archers is lost.  (There is no ai function to read the current preference value.)
*/

// Random map name.  Can be set in setParameters to make scenario AI's adopt map-specific behaviors.  Must be set in setParameters() to be
// used, there is no way to activate it later.

extern string cvRandomMapName="None";    


extern bool    cvTransportMap = false;    // Set this to true in setParameters() to tell AI to make transports.  Note: if left
                                          // false, the init() functions may set it true if its a watery map.  If you want
                                          // to be sure it won't use transports, call setTransportMap(false) in setOverrides() as well.
extern bool    cvWaterMap = false;

extern int     cvMapSubType = -1;

// special maps
extern const int KOTHMAP = 1;
extern const int NOMADMAP = 2;
extern const int SHIMOMAP = 3;
extern const int VINLANDSAGAMAP = 4;
extern const int WATERNOMADMAP = 5;
// for shimo kinda maps
extern int gShimoKingUnitTypeID = cUnitTypeArkantos; 
extern int gShimoKingID = -1; // the unit ID for our king!
// nothing special for start...
extern int cvMapSubType = -1;

//for trigonometric functions
extern float PI = 3.141592;

// Reth Placeholder
extern bool ShowAiEcho = false;
extern bool DisallowPullBack = false;
extern int KOTHTransportPlan = -1;
extern int KOTHTHomeTransportPlan = -1;
extern int SendBackCount = 0;
extern bool KoTHOkNow = false;
extern bool DestroyTransportPlan = false;  
extern bool DestroyHTransportPlan = false;
extern bool DestroyKOTHLandPlan = false;
extern int gTowerEscrowID=cMilitaryEscrowID;
mutable void towerInBase( string planName="BUG", bool los = true, int numTowers = 6, int escrowID=-1 ) { }
//==============================================================================
int getAreaGroupByArea(int areaID=-1)   //this is such shit, but there is no other possibility
                                        //as far as I can see :-(
{
   if (ShowAiEcho == true) aiEcho("getAreaGroupByArea:");    
   
   vector loc = kbAreaGetCenter(areaID);
   return (kbAreaGroupGetIDByPosition(loc));
}

//==============================================================================
bool equal(vector left=cInvalidVector, vector right=cInvalidVector) //true if the given vectors are equal
{
   //if (ShowAiEcho == true) aiEcho("equal:");    
  
   float lx = xsVectorGetX( left );
   float ly = xsVectorGetY( left );
   float lz = xsVectorGetZ( left );
   float rx = xsVectorGetX( right );
   float ry = xsVectorGetY( right );
   float rz = xsVectorGetZ( right );

   if ( lx == rx &&
        ly == ry &&
        lz == rz )
   {
      return(true);
   }

   return(false);
}

// *****************************************************************************
// configQuery
//
// Sets up all the non-default parameters so you can config a query on a single call.
// Query must be created prior to calling, and the results reset and the query executed
// after the call.
// ***************************************************************************** 
bool  configQuery( int queryID = -1, int unitType = -1, int action = -1, int state = -1, int player = -1, 
                    vector center = cInvalidVector, bool sort = false, float radius = -1, bool seeable = false, int areaID = -1 )
{
    //if (ShowAiEcho == true) aiEcho("configQuery:");    

    if ( queryID == -1)
    {
        if (ShowAiEcho == true) aiEcho("Invalid query ID");
        return(false);
    }

    if (player != -1)
        kbUnitQuerySetPlayerID(queryID, player);
   
    if (unitType != -1)
        kbUnitQuerySetUnitType(queryID, unitType);

    if (action != -1)
        kbUnitQuerySetActionType(queryID, action);

    if (state != -1)
        kbUnitQuerySetState(queryID, state);

    if (equal(center, cInvalidVector) == false)
    {
        kbUnitQuerySetPosition(queryID, center);
        if (sort == true)
            kbUnitQuerySetAscendingSort(queryID, true);
        if (radius != -1)
            kbUnitQuerySetMaximumDistance(queryID, radius);
    }

    if (areaID != -1)
        kbUnitQuerySetAreaID(queryID, areaID);
   
    if (seeable == true)
        kbUnitQuerySetSeeableOnly(queryID, true);
        
    return(true);
}

// *****************************************************************************
// configQueryRelation
//
// Sets up all the non-default parameters so you can config a query on a single call.
// Query must be created prior to calling, and the results reset and the query executed
// after the call.
// Unlike configQuery(), this uses the PLAYER RELATION rather than the player number
// ***************************************************************************** 
bool  configQueryRelation( int queryID = -1, int unitType = -1, int action = -1, int state = -1, int playerRelation = -1, 
                            vector center = cInvalidVector, bool sort = false, float radius = -1, bool seeable = false, int areaID = -1 )
{
    //if (ShowAiEcho == true) aiEcho("configQueryRelation:");

    if ( queryID == -1)
    {
        if (ShowAiEcho == true) aiEcho("Invalid query ID");
        return(false);
    }

    if (playerRelation != -1)
        kbUnitQuerySetPlayerRelation(queryID, playerRelation);
   
    if (unitType != -1)
        kbUnitQuerySetUnitType(queryID, unitType);

    if (action != -1)
        kbUnitQuerySetActionType(queryID, action);

    if (state != -1)
        kbUnitQuerySetState(queryID, state);

    if (equal(center, cInvalidVector) == false)
    {
        kbUnitQuerySetPosition(queryID, center);
        if (sort == true)
            kbUnitQuerySetAscendingSort(queryID, true);
        if (radius != -1)
            kbUnitQuerySetMaximumDistance(queryID, radius);
    }

    if (areaID != -1)
        kbUnitQuerySetAreaID(queryID, areaID);
   
    if (seeable == true)
        kbUnitQuerySetSeeableOnly(queryID, true);
    
    return(true);
}

//==============================================================================
// guessEnemyLocation --- returns the assumed location of the enemy town
// TODO: currently works for 1v1. Bad results for 1v2 (every even number of
// enemies)
//==============================================================================
vector guessEnemyLocation()
{
    if (ShowAiEcho == true) aiEcho("guessEnemyLocation:");

    static vector enemyLoc = cInvalidVector;
    // don't guess again.
    if ( equal(enemyLoc, cInvalidVector) == true )
    { 
        //-- calculate the location to vision
        //-- find the center of the map
        vector vCenter = kbGetMapCenter();
        vector vTC = kbGetTownLocation();
        float centerx = xsVectorGetX(vCenter);
        float centerz = xsVectorGetZ(vCenter);
        float xoffset =  centerx - xsVectorGetX(vTC);
        float zoffset =  centerz - xsVectorGetZ(vTC);

        centerx = centerx + xoffset + aiRandInt(12) - aiRandInt(6);
        centerz = centerz + zoffset + aiRandInt(12) - aiRandInt(6);

        //-- reflected across the center
        enemyLoc = xsVectorSetX(enemyLoc, centerx);
        enemyLoc = xsVectorSetZ(enemyLoc, centerz);
    }
    return(enemyLoc);
}

//==============================================================================
bool isOnMyIsland(vector there=cInvalidVector)
{
    if (ShowAiEcho == true) aiEcho("isOnMyIsland:");

    //Get our initial location.
    vector here=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    int myAreaGroupID = kbAreaGroupGetIDByPosition(here);
    int islandGroupID=kbAreaGroupGetIDByPosition(there);
    return(myAreaGroupID==islandGroupID);
}

//==============================================================================
bool hasWaterNeighbor(int areaID = -1)    // True if the test area has a water area neighbor
{
    if (ShowAiEcho == true) aiEcho("hasWaterNeighbor:");

    int areaCount = -1;
    int areaIndex = -1;
    int testArea = -1;
    bool hasWater = false;

    areaCount = kbAreaGetNumberBorderAreas(areaID);
    if (areaCount > 0)
    {
        for (areaIndex=0; < areaCount)
        {
            testArea = kbAreaGetBorderAreaID(areaID, areaIndex);
            if ( kbAreaGetType(testArea) == cAreaTypeWater )
                hasWater = true;
        }
    }
    if (hasWater == true)
        if (ShowAiEcho == true) aiEcho("    "+areaID+" has a water neighbor.");

    return(hasWater);
}

//==============================================================================
int verifyVinlandsagaBase(int goalAreaID = -1, int recurseCount = 3)    //verify that this area borders water, find another if it doesn't.
{
    if (ShowAiEcho == true) aiEcho("verifyVinlandsagaBase:");

    int newAreaID = goalAreaID;      // New area will be the one we use.  By default,
                                    // we'll start with the one passed to us.
    bool done = false;               // Set true when we find an acceptable one
    int index = -1;                  // Which number are we checking
    int areaCount = -1;              // How many areas to search
    int testArea = -1;


    if (hasWaterNeighbor(goalAreaID) == true)    // Simple case
    {
        //if (ShowAiEcho == true) aiEcho("Target area "+goalAreaID+" has a water neighbor...using it.");
        return(goalAreaID);
    }
    int recurseLevel = 0;
    if (recurseCount > 0)
    {
        for (recurseLevel=0; < recurseCount)
        {
            //if (ShowAiEcho == true) aiEcho("Area "+goalAreaID+" has "+kbAreaGetNumberBorderAreas(goalAreaID)+" neighbors.");
            //if (ShowAiEcho == true) aiEcho("Testing "+(recurseLevel+1)+" layers around area "+goalAreaID);
            // Test each area that borders each border area.  
            for (index=0; < kbAreaGetNumberBorderAreas(goalAreaID))  // Get each border area
            {
                testArea = kbAreaGetBorderAreaID(goalAreaID, index);
                if (verifyVinlandsagaBase(testArea, recurseLevel) > 0)
                {
                    return(testArea);
                }
            }
        }
    }

    if (recurseCount == 3)     // Sigh, just fail and return -1.
        if (ShowAiEcho == true) aiEcho("Couldn't find a water-bordered area.");
    return(-1);
}

//==============================================================================
// some trigonometric functions stolen from The Void RMS by Wolfenhex
// Many thanks to Wolfenhex for providing these functions
// His RMS can be found here:
// http://aom.heavengames.com/downloads/showfile.php?fileid=1377
//==============================================================================
float _pow(float n = 0,int x = 0) 
{
    //if (ShowAiEcho == true) aiEcho("_pow:");

    float r = n;
    for (i = 1; < x) 
    {
        r = r * n;
    }
    return (r);
}

float _atan(float n = 0) 
{
    //if (ShowAiEcho == true) aiEcho("_atan:");

    float m = n;
    if (n > 1)
        m = 1.0 / n;
    if (n < -1) 
        m = -1.0 / n;
    float r = m;
    for (i = 1; < 100) 
    {
        int j = i * 2 + 1;
        float k = _pow(m,j) / j;
        if (k == 0) 
            break;
        if (i % 2 == 0) 
            r = r + k;
        if (i % 2 == 1) 
            r = r - k;
    }
    if (n > 1 || n < -1) 
        r = PI / 2.0 - r;
    if (n < -1) 
        r = 0.0 - r;
    return (r);
}

float _atan2(float z = 0,float x = 0) 
{
    //if (ShowAiEcho == true) aiEcho("_atan2:");

    if (x > 0) 
        return (_atan(z / x));
    if (x < 0) 
    {
        if (z < 0) 
            return (_atan(z / x) - PI);
        if (z > 0) 
            return (_atan(z / x) + PI);
        return (PI);
    }
    if (z > 0) 
        return (PI / 2.0);
    if (z < 0) 
        return (0.0 - (PI / 2.0));
    return (0);
}

float _fact(float n = 0) 
{
    //if (ShowAiEcho == true) aiEcho("_fact:");

    float r = 1;
    for (i = 1; <= n) 
    {
        r = r * i;
    }
    return (r);
}

float _cos(float n = 0) 
{
    //if (ShowAiEcho == true) aiEcho("_cos:");

    float r = 1;
    for (i = 1; < 100) 
    {
        int j = i * 2;
        float k = _pow(n,j) / _fact(j);
        if (k == 0) 
            break;
        if (i % 2 == 0) 
            r = r + k;
        if (i % 2 == 1) 
            r = r - k;
    }
    return (r);
}

float _sin(float n = 0) 
{
    //if (ShowAiEcho == true) aiEcho("_sin:");

    float r = n;
    for (i = 1; < 100) 
    {
        int j = i * 2 + 1;
        float k = _pow(n,j) / _fact(j);
        if (k == 0) 
            break;
        if (i % 2 == 0) 
            r = r + k;
        if (i % 2 == 1) 
            r = r - k;
    }
    return (r);
}

//==============================================================================
vector findForwardBasePos()
{
    if (ShowAiEcho == true) aiEcho("findForwardBasePos:");
    
    static vector forwardBasePos = cInvalidVector;
    // don't calculate again.
    if ( equal(forwardBasePos, cInvalidVector) == true )
    { 
        float radius=100.0;

        vector vCenter = kbGetMapCenter();
        vector enemyPos = guessEnemyLocation();
        vector dirToCenter = vCenter - enemyPos;
        vector normalized = xsVectorNormalize(dirToCenter);
        float rnd=aiRandInt(20);
        rnd = rnd/20.0;
        float p=PI*-0.33;
        p = p+(PI*0.33*rnd);
        float q = _atan2(xsVectorGetZ(normalized), xsVectorGetX(normalized));
        float c = _cos(q+p);
        float s = _sin(q+p);
        float x = xsVectorGetX(enemyPos) + (c * radius);
        float z = xsVectorGetZ(enemyPos) + (s * radius);
        forwardBasePos = xsVectorSetX(forwardBasePos, x);
        forwardBasePos = xsVectorSetZ(forwardBasePos, z);

        // we do not need to test AGID's if we are on a land map
        if (gTransportMap == false)
        {
            return(forwardBasePos);
        }

        int enemyAGID = kbAreaGroupGetIDByPosition(enemyPos);
        int i = -1;
        vector towardHim = enemyPos - forwardBasePos;
        towardHim = towardHim / 10;    // 10% of distance from forward base to him
        bool success = false;
        int forwardAGID = -1;

        for (i = 0; < 9)    // Keep testing until areaGroups match
        {
            forwardAGID = kbAreaGroupGetIDByPosition(forwardBasePos);
            if (enemyAGID == forwardAGID)
            {
                success = true;

                // ensure that we get an area at coast.
                int areaID = kbAreaGetIDByPosition(forwardBasePos);
                areaID = verifyVinlandsagaBase(areaID);
                forwardBasePos = kbAreaGetCenter(areaID);
                break;
            }
            else
            {
                forwardBasePos = forwardBasePos + towardHim;   // Try a bit closer
            }
        }
        if (success == false)
        {
            forwardBasePos = cInvalidVector;
        }
    }
    return(forwardBasePos);
}


//==============================================================================
int getPlayerForIsland(int AGID=-1)
{
    if (ShowAiEcho == true) aiEcho("getPlayerForIsland:");

    int hasMost=-1;
    int max=0;
    int cur=0;

    for (i=0; < cNumberPlayers)
    {
        cur=kbUnitCount(i, -1, cUnitStateAlive);
        if (cur > max)
        {
            max=cur;
            hasMost=i;
        }
    }
    return(hasMost);
}

//==============================================================================
// findUnit // Will find a random unit of the given playerID
//==============================================================================
int findUnit(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1, 
                int playerID = cMyID, vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    int count = -1;
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("randFindUnitQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQuery(unitQueryID, unitTypeID, action, state, playerID, center, true, radius, seeable, areaID);   //sort = true
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
        return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));
    return(-1);
}

//==============================================================================
// findUnitByRel    // Will find a random unit of the given playerRelation
//==============================================================================
int findUnitByRel(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1, int playerRelation = cPlayerRelationSelf,
                         vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    int count = -1;
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("randFindUnitByRelQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQueryRelation(unitQueryID, unitTypeID, action, state, playerRelation, center, true, radius, seeable, areaID); //sort = true
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
        return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));
    return(-1);
}

//==============================================================================
// findUnitByIndex  // Will find a unit of the given playerID by the index, default index = 0
//==============================================================================
int findUnitByIndex(int unitTypeID = -1, int index = 0, int state = cUnitStateAlive, int action = -1, int playerID = cMyID, 
                        vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    //if (ShowAiEcho == true) aiEcho("findUnitByIndex:");

    int count = -1;
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("findUnitByIndexQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQuery(unitQueryID, unitTypeID, action, state, playerID, center, true, radius, seeable, areaID);  //sort = true
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
        return(kbUnitQueryGetResult(unitQueryID, index));
    return(-1);
}

//==============================================================================
// findUnitByRelByIndex // Will find a random unit of the given playerRelation
//==============================================================================
int findUnitByRelByIndex(int unitTypeID = -1, int index = 0, int state = cUnitStateAlive, int action = -1, 
                            int playerRelation = cPlayerRelationSelf, vector center = cInvalidVector, float radius = -1, 
                                bool seeable = false, int areaID = -1)
{
    //if (ShowAiEcho == true) aiEcho("findUnitByRelByIndex:");
    
    int count = -1;
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID=kbUnitQueryCreate("randFindUnitByRelByIndexQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQueryRelation(unitQueryID, unitTypeID, action, state, playerRelation, center, true, radius, seeable, areaID); //sort = true
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
        return(kbUnitQueryGetResult(unitQueryID, index));
    return(-1);
}

//==============================================================================
// getNumUnits  // Returns the number of units of the given playerID (within the radius of a position)
//==============================================================================
int getNumUnits(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1, 
                 int playerID = cMyID, vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    //if (ShowAiEcho == true) aiEcho("getNumUnits:");

    int count = -1;
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("getNumUnitsQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQuery(unitQueryID, unitTypeID, action, state, playerID, center, false, radius, seeable, areaID);
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
    return(numberFound);
}

//==============================================================================
// getNumUnitsByRel // Returns the number of units of the given playerRelation (within the radius of a position)
//==============================================================================
int getNumUnitsByRel(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1, int playerRelation = cPlayerRelationSelf,
                        vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    //if (ShowAiEcho == true) aiEcho("getNumUnitsByRel:");
    
    int count = -1;
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("getNumUnitsByRelQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQueryRelation(unitQueryID, unitTypeID, action, state, playerRelation, center, false, radius, seeable, areaID);
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
    return(numberFound);
}

//==============================================================================
vector getMainBaseMilitaryGatherPoint()
{
    if (ShowAiEcho == true) aiEcho("******** getMainBaseMilitaryGatherPoint");

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector militaryGatherPoint = cInvalidVector;
    static float radius = 30.0;
    int gatherPointUnitIDNearMainBase = -1;
    for (i = 0; < 2)
    {
        if (gAge3MinorGod == cTechAge3Apollo)
            gatherPointUnitIDNearMainBase = findUnitByIndex(cUnitTypeTemple, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, radius);
        else if (gAge2MinorGod == cTechAge2Forseti)
            gatherPointUnitIDNearMainBase = findUnitByIndex(cUnitTypeHealingSpringObject, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, radius);    
    
        if (gatherPointUnitIDNearMainBase < 0)
        {
            radius = radius + 20.0;
            //if (ShowAiEcho == true) aiEcho("increasing radius to find gatherPointUnitIDNearMainBase");
        }
        else
        {
            militaryGatherPoint = kbUnitGetPosition(gatherPointUnitIDNearMainBase);
            radius = 30.0;
            break;
        }
    }
    if (equal(militaryGatherPoint, cInvalidVector) == true)
    {
        vector baseFront = xsVectorNormalize(kbGetMapCenter() - mainBaseLocation);
        militaryGatherPoint = mainBaseLocation + baseFront * 18;
    }
    //if (ShowAiEcho == true) aiEcho("our military gather point is: "+militaryGatherPoint);
    return(militaryGatherPoint);
}


//==============================================================================
int getMainBaseUnitIDForPlayer(int playerID = -1)
{
    //if (ShowAiEcho == true) aiEcho("getMainBaseUnitIDForPlayer: "+playerID);
    
    int numSettlements = kbUnitCount(playerID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    if (numSettlements < 1)
    {
        //if (ShowAiEcho == true) aiEcho("no enemy settlements (sighted yet), returning -1");
        return(-1);
    }    
    
    int mainBaseUnitID = -1;

    int mainBaseID = kbBaseGetMainID(playerID); //For some reason the mainBaseID of enemies usually isn't a settlement base!
    vector mainBaseLocation = kbBaseGetLocation(playerID, mainBaseID);  //doesn't actually return the settlement position
    float radius = 15.0;
    for (i = 0; < 4)
    {
        mainBaseUnitID = findUnitByIndex(cUnitTypeAbstractSettlement, 0, cUnitStateAlive, -1, playerID, mainBaseLocation, radius);
        if (mainBaseUnitID < 0)
        {
            radius = radius + 15.0;
        }
        else
        {
            break;
        }
    }
    
    if (mainBaseUnitID < 0)
    {
        for (i = 0; < numSettlements)
        {
            int settlementID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive, -1, playerID);
            if (settlementID != -1)
            {
                vector settlementLocation = kbUnitGetPosition(settlementID);
                int numTowersInR50 = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, playerID, settlementLocation, 50.0);
                int numFarmsInR30 = getNumUnits(cUnitTypeFarm, cUnitStateAlive, -1, playerID, settlementLocation, 30.0);
                if ((numTowersInR50 > 3) || (numFarmsInR30 > 6))    //TODO: rework and improve the main base detection!
                {
                    mainBaseUnitID = settlementID;
                    break;
                }
            }
        }
    }
    return(mainBaseUnitID);
}

//==============================================================================
int findNumUnitsInBase(int playerID = 0, int baseID = -1, int unitTypeID = -1, int state = cUnitStateAliveOrBuilding)
{
    if (ShowAiEcho == true) aiEcho("findNumUnitsInBase:");

    int count = -1;
    static int unitQueryID = -1;

    //Create the query if we don't have it.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("getUnitsInBaseQuery");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
    {
        kbUnitQuerySetPlayerID(unitQueryID, playerID);
        kbUnitQuerySetBaseID(unitQueryID, baseID);
        kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
        kbUnitQuerySetState(unitQueryID, state);
    }
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
    return(kbUnitQueryExecute(unitQueryID));
}

//==============================================================================
int getPlanPopSlots(int planID=-1)  //Returns the total pop slots taken by units in this plan
{
    if (ShowAiEcho == true) aiEcho("getPlanPopSlots:");

    int unitCount = aiPlanGetNumberUnits(planID, cUnitTypeUnit);
    return(3 * unitCount);
}  

//==============================================================================
int createSimpleAttackGoal(string name="BUG", int attackPlayerID=-1,
    int unitPickerID=-1, int repeat=-1, int minAge=-1, int maxAge=-1,
    int baseID=-1, bool allowRetreat=false)
{
    if (ShowAiEcho == true) aiEcho("CreateSimpleAttackGoal:  Name="+name+", AttackPlayerID="+attackPlayerID+".");

    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Priority.
    aiPlanSetDesiredPriority(goalID, 90);
    //Attack player ID.
    if (attackPlayerID >= 0)
        aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
    else
        aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
    //Base.
    if (baseID >= 0)
        aiPlanSetBaseID(goalID, baseID);
    else
        aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateBase, 0, true);
    //Attack.
	aiPlanSetAttack(goalID, true);
	aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeAttack);
	aiPlanSetVariableInt(goalID, cGoalPlanAttackStartFrequency, 0, 5);
    //Military.
    aiPlanSetMilitary(goalID, true);
    aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);
    //Unit Picker.
    aiPlanSetVariableInt(goalID, cGoalPlanUnitPickerID, 0, unitPickerID);
    //Retreat.
    aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, allowRetreat);
    // Upgrade Building prefs.
	
    aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 3, true);
    aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeTemple);
    aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeSettlementLevel1);
    if (cMyCiv == cCivThor)
        aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeDwarfFoundry);
    else
        aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeArmory);
		
    //Handle maps where the enemy player is usually on a diff island.
    if (gTransportMap == true)
    {
        aiPlanSetVariableBool(goalID, cGoalPlanSetAreaGroups, 0, true);
        aiPlanSetVariableInt(goalID, cGoalPlanAttackRoutePatternType, 0, cAttackPlanAttackRoutePatternBest);
    }
    // Handle OkToAttack control variable
    if (cvOkToAttack == false)     
    {
        aiPlanSetVariableBool(goalID, cGoalPlanIdleAttack, 0, true);       // Prevent attacks
    }

    //Done.
    return(goalID);
}

//==============================================================================
int createBaseGoal(string name="BUG", int goalType=-1, int attackPlayerID=-1,
    int repeat=-1, int minAge=-1, int maxAge=-1, int parentBaseID=-1)
{
    if (ShowAiEcho == true) aiEcho("CreateBaseGoal:  Name="+name+", AttackPlayerID="+attackPlayerID+".");

    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Priority.
    aiPlanSetDesiredPriority(goalID, 90);
    //"Parent" Base.
    aiPlanSetBaseID(goalID, parentBaseID);
    //Base Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, goalType);
    if (goalType == cGoalPlanGoalTypeForwardBase)
    {
        //Attack player ID.
        if (attackPlayerID >= 0)
            aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
        else
            aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
        //Military.
        aiPlanSetMilitary(goalID, true);
        aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
        //Active health.
        aiPlanSetVariableInt(goalID, cGoalPlanActiveHealthTypeID, 0, cUnitTypeBuilding);
        aiPlanSetVariableFloat(goalID, cGoalPlanActiveHealth, 0, 0.25);
    }
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

    //Done.
    return(goalID);
}

//==============================================================================
int createCallbackGoal(string name="BUG", string callbackName="BUG", int repeat=-1,
    int minAge=-1, int maxAge=-1, bool autoUpdate=false)
{
    if (ShowAiEcho == true) aiEcho("CreateCallbackGoal:  Name="+name+", CallbackName="+callbackName+".");

    //Get the callbackFID.
    int callbackFID=xsGetFunctionID(callbackName);
    if (callbackFID < 0)
        return(-1);

    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Goal Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeCallback);
    //Auto update.
    aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
    //Callback FID.
    aiPlanSetVariableInt(goalID, cGoalPlanFunctionID, 0, callbackFID);
    //Priority.
    aiPlanSetDesiredPriority(goalID, 90);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

    //Done.
    return(goalID);
}

//==============================================================================
int createBuildBuildingGoal(string name="BUG", int buildingTypeID=-1, int repeat=-1,
    int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
    bool autoUpdate=true, int pri=90, int buildingPlacementID = -1)
{
    if (ShowAiEcho == true) aiEcho("CreateBuildBuildingGoal:  Name="+name+", BuildingType="+kbGetUnitTypeName(buildingTypeID)+".");

    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Goal Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuilding);
    //Base ID.
    aiPlanSetBaseID(goalID, baseID);
    //Auto update.
    aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
    //Building Type ID.
    aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
    //Building Placement ID.
    aiPlanSetVariableInt(goalID, cGoalPlanBuildingPlacementID, 0, buildingPlacementID);
    //Set the builder parms.
    aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
    aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
   
    //Priority.
    aiPlanSetDesiredPriority(goalID, pri);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

    //Done.
    return(goalID);
}

//==============================================================================
int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
    bool autoUpdate=true, int pri=90)
{
    int buildingTypeID = cUnitTypeSettlementLevel1;

    if (ShowAiEcho == true) aiEcho("CreateBuildSettlementGoal:  Name="+name+", BuildingType="+kbGetUnitTypeName(buildingTypeID)+".");

    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Goal Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuildSettlement);
    //Base ID.
    aiPlanSetBaseID(goalID, baseID);
    //Auto update.
    aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
    //Building Type ID.
    aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
    //Building Search ID.
    aiPlanSetVariableInt(goalID, cGoalPlanBuildingSearchID, 0, cUnitTypeSettlement);
    //Set the builder parms.
    aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
    aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
   
    //Priority.
    aiPlanSetDesiredPriority(goalID, pri);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, 1);

    //Done.
    return(goalID);
}

//==============================================================================
int createTransportPlan(string name="BUG", int startAreaID=-1, int goalAreaID=-1,
    bool persistent=false, int transportPUID=-1, int pri=-1, int baseID=-1)
{
    if (ShowAiEcho == true) aiEcho("CreateTransportPlan:  Name="+name+", Priority="+pri+".");

    //Create the plan.
    int planID=aiPlanCreate(name, cPlanTransport);
    if (planID < 0)
        return(-1);

    //Priority.
    aiPlanSetDesiredPriority(planID, pri);
    //Base.
    aiPlanSetBaseID(planID, baseID);
    //Set the areas.
    aiPlanSetVariableInt(planID, cTransportPlanPathType, 0, 1);
    aiPlanSetVariableInt(planID, cTransportPlanGatherArea, 0, startAreaID);
    aiPlanSetVariableInt(planID, cTransportPlanTargetArea, 0, goalAreaID);
    //Default the initial position to the start area's location.
    aiPlanSetInitialPosition(planID, kbAreaGetCenter(startAreaID));
    //Transport type.
    aiPlanSetVariableInt(planID, cTransportPlanTransportTypeID, 0, transportPUID);
    //Persistent.
    aiPlanSetVariableBool(planID, cTransportPlanPersistent, 0, persistent);
    //Always add the transport unit type.
    aiPlanAddUnitType(planID, transportPUID, 1, 1, 1);
    //Activate.
    aiPlanSetActive(planID);

    //Done.
    return(planID);
}

//==============================================================================
int getEconPop(void)    //Returns the unit count of villagers, dwarves, fishing boats, trade carts and oxcarts
{
    if (ShowAiEcho == true) aiEcho("getEconPop:");

    int retVal = 0;

    retVal = retVal + kbUnitCount(cMyID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 0), cUnitStateAlive);
    retVal = retVal + kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
    if (cMyCulture == cCultureNorse)
    {
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeFishingShipNorse, cUnitStateAlive);
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeOxCart, cUnitStateAlive);
    }
    else if (cMyCulture == cCultureGreek)
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeFishingShipGreek, cUnitStateAlive);
    else if (cMyCulture == cCultureEgyptian)
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeFishingShipEgyptian, cUnitStateAlive);
    else if (cMyCulture == cCultureAtlantean)
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeFishingShipAtlantean, cUnitStateAlive);   
	else if (cMyCulture == cCultureChinese)
        retVal = retVal + kbUnitCount(cMyID, cUnitTypeFishingShipChinese, cUnitStateAlive);   	
    
    return(retVal);
}

//==============================================================================
int getMilPop(void) //Returns the pop slots used by military units
{
    if (ShowAiEcho == true) aiEcho("getMilPop:");

    return(kbGetPop() - getEconPop());
}

//==============================================================================
vector findBestSettlement(int playerID=0)   //Will find the closet settlement of the given playerID
{
    if (ShowAiEcho == true) aiEcho("findBestSettlement:");

    int count=-1;
    int numberFound=-1;
    static int unitQueryID=-1;
    vector townLocation=kbGetTownLocation();
    vector forwardLocation=cInvalidVector;
    vector best=cInvalidVector;
    best=townLocation;

    //Create the query if we don't have it yet.
    if (unitQueryID < 0)
        unitQueryID=kbUnitQueryCreate("getUnClaimedSettlements");
   
    //Define a query to get all matching units.
    if (unitQueryID != -1)
    {
        kbUnitQuerySetPlayerID(unitQueryID, playerID);
        kbUnitQuerySetUnitType(unitQueryID, cUnitTypeSettlement);
        kbUnitQuerySetState(unitQueryID, cUnitStateAny);
    }
    else
        return(cInvalidVector);

    //Find the best one.
    float bestDistSqr=100000000.0;
    kbUnitQueryResetResults(unitQueryID);
    numberFound=kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
    {
        vector position=kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i));
        float dx=xsVectorGetX(townLocation)-xsVectorGetX(position);
        float dz=xsVectorGetZ(townLocation)-xsVectorGetZ(position);
      
        float curDistSqr=((dx*dx) + (dz*dz));
        if (curDistSqr < bestDistSqr)
        {
            best=position;
            bestDistSqr=curDistSqr;
        }
    }
    return(best);
}

//==============================================================================
// claimSettlement
// @param where: the position of the settlement to claim
// @param baseID: the base to get the builders from. If left unspecified, the
//                funct will try to find builders
//==============================================================================
void claimSettlement(vector where=cInvalidVector, int baseToUseID=-1)
{
    if (ShowAiEcho == true) aiEcho("claimSettlement:");    
    
    int baseID=-1;
    int startAreaID=-1;
    static int builderQuery=-1;
    int builderTypeID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
    if ( builderTypeID < 0 )
        return;

    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    if (transportPUID < 0)
        return;

    // user specified a base, use it!
    if ( baseToUseID != -1 )
    {
        baseID = baseToUseID;
    }
    else
    {
        if (builderQuery < 0)
        {
            builderQuery = kbUnitQueryCreate("Idle Builder Query");
            configQuery( builderQuery, builderTypeID, cActionIdle, cUnitStateAny, cMyID);
        }

        int numBases=kbBaseGetNumber(cMyID);
        for ( i = 0; < numBases )
        {
            // the base 0 one is our mainbase, but I want to find idle builders on other bases,
            // for example builders that created a settlement earlier. These builders will be idle until the end 
            // of the game otherwise (for now, at least :-( ). By starting the queries with the last base, i hope to catch exactly
            // these builders...TODO: Test!
            kbUnitQuerySetBaseID(builderQuery, numBases-1-i);
            kbUnitQueryResetResults(builderQuery);
            int numberFound=kbUnitQueryExecute(builderQuery);

            // this is our start base!
            if ( numberFound >= 3 )
            {
                baseID = i;
                break;
            }
        }
    }

    if ( baseID == -1 ) // no base found, use mainbase!
    {
        baseID = kbBaseGetMainID(cMyID);
    }

    vector baseLoc = kbBaseGetLocation(cMyID, baseID); 
    startAreaID = kbAreaGetIDByPosition(baseLoc);

    int remoteSettlementTransportPlan = -1;
    remoteSettlementTransportPlan=createTransportPlan("Remote Settlement Transport", startAreaID, kbAreaGetIDByPosition(where),
                                                      false, transportPUID, 80, baseID);

    // add the builders to the transport plan
    aiPlanAddUnitType( remoteSettlementTransportPlan, builderTypeID, 3, 3, 3 );

    //Done with transport plan. build a settlement now!
    int planID=aiPlanCreate("Build Remote"+kbGetUnitTypeName(cUnitTypeSettlementLevel1),
                           cPlanBuild);
    if (planID < 0)
        return;
    //Puid.
    aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
    //Priority.
    aiPlanSetDesiredPriority(planID, 80);
    aiPlanSetEconomy(planID, true);
    //Escrow.
    aiPlanSetEscrowID(planID, cEconomyEscrowID);
    //Builders.
    aiPlanAddUnitType(planID, builderTypeID, 3, 3, 3);
    //Location.
    aiPlanSetInitialPosition(planID, where);
    aiPlanSetVariableVector(planID, cBuildPlanSettlementPlacementPoint, 0, where);
    //Go.
    aiPlanSetActive(planID);
}

//==============================================================================
bool findASettlement()  //Will find an unclaimed settlement
{
    //if (ShowAiEcho == true) aiEcho("findASettlement:");

    int count=-1;
    static int unitQueryID=-1;

    //Create the query if we don't have it yet.
    if (unitQueryID < 0)
        unitQueryID=kbUnitQueryCreate("getAnUnClaimedSettlements");
   
    //Define a query to get all matching units.
    if (unitQueryID != -1)
    {
        kbUnitQuerySetPlayerID(unitQueryID, 0);
        kbUnitQuerySetUnitType(unitQueryID, cUnitTypeSettlement);
        kbUnitQuerySetState(unitQueryID, cUnitStateAny);
    }
    else
        return(false);

    kbUnitQueryResetResults(unitQueryID);
    int numberFound=kbUnitQueryExecute(unitQueryID);
    if (numberFound > 0)
        return(true);
    return(false);
}

//==============================================================================
int findBiggestBorderArea(int areaID=-1)    //given an area ID, find the biggest border area in tiles
{
    if (ShowAiEcho == true) aiEcho("findBiggestBorderArea:");

    if (areaID == -1)
        return(-1);

    int numBorders=kbAreaGetNumberBorderAreas(areaID);
    int borderArea=-1;
    int numTiles=-1;
    int bestTiles=-1;
    int bestArea=-1;

    for (i=0; < numBorders)
    {
        borderArea=kbAreaGetBorderAreaID(areaID, i);
        numTiles=kbAreaGetNumberTiles(borderArea);
        if (numTiles > bestTiles)
        {
            bestTiles=numTiles;
            bestArea=borderArea;
        }
    }

    return(bestArea);
}

//==============================================================================
int newResourceBase(int oldResourceBase=-1, int resourceID=-1)
{
    if (ShowAiEcho == true) aiEcho("newResourceBase:");

    int queryUnitID=cUnitTypeGold;
    if (resourceID==cResourceWood)
        queryUnitID=cUnitTypeTree;

    static int resourceQueryID=-1;
    if (resourceQueryID < 0)
        resourceQueryID=kbUnitQueryCreate("Resource Query");
    configQuery(resourceQueryID, queryUnitID, -1, cUnitStateAlive, 0, kbBaseGetLocation(cMyID, kbBaseGetMain(cMyID)), true);
    kbUnitQueryResetResults(resourceQueryID);
    int numResults = kbUnitQueryExecute(resourceQueryID);

    if ( numResults <= 0 )
    {
        //if (ShowAiEcho == true) aiEcho("newResourceBase: no resources found, return!");
        return(-1);
    }
    vector there = kbUnitGetPosition(kbUnitQueryGetResult(resourceQueryID, 0)); // just take the closest
   
    // nothing to do then. Should not happen anyway, because of findCreateResourceBase()
    // see updateGoldBreakdown and updateWoodBreakdown
    if ( isOnMyIsland(there) )
    {
        //if (ShowAiEcho == true) aiEcho("newResourceBase: resource found on my island, return!");
        return(-1);
    }

    //Create transport plan to get vills to the other island
    // but just do one per detected resource site!
    // therefore remember the pos where we did the transport to
    if (resourceID==cResourceGold)
    {
        static vector gTransportToGoldPos = cInvalidVector;
        // been there, done that
        if ( equal(gTransportToGoldPos, there) )
        {
            //if (ShowAiEcho == true) aiEcho("newResourceBase: already transported vills to gold position, return!");
            return(-1);
        }
    }
    else if (resourceID==cResourceWood)
    {
        static vector gTransportToWoodPos = cInvalidVector;
        // been there, done that
        if ( equal(gTransportToWoodPos, there) )
        {
            //if (ShowAiEcho == true) aiEcho("newResourceBase: already transported vills to wood position, return!");
            return(-1);
        }
    }

    //Get our initial location.
    int startBaseID = -1;
    if ( oldResourceBase >= 0 )
        startBaseID = oldResourceBase;
    else
        startBaseID = kbBaseGetMainID(cMyID);
    vector here=kbBaseGetLocation(cMyID, startBaseID);
    int startAreaID=kbAreaGetIDByPosition(here);

    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    if (transportPUID < 0)
    {
        //if (ShowAiEcho == true) aiEcho("newResourceBase: no transport unit type, return!");
        return(-1);
    }

    int resurceTransportPlan = -1;
    resurceTransportPlan=createTransportPlan("Remote Resource Transport", startAreaID, kbAreaGetIDByPosition(there), false, transportPUID, 80, startBaseID);

    // TODO: add all dwarves
    int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
    int numVills = 0.5 + aiGetResourceGathererPercentage(resourceID, cRGPActual) * gathererCount;
    aiPlanAddUnitType(resurceTransportPlan, cUnitTypeAbstractVillager, numVills, numVills, numVills);
    if ( cMyCulture == cCultureNorse )
        aiPlanAddUnitType( resurceTransportPlan, cUnitTypeOxCart, 1, 1, 1 );

    aiPlanSetRequiresAllNeedUnits( resurceTransportPlan, true );
    aiPlanSetActive(resurceTransportPlan);

    // remember the position that we did the transport to.
    if (resourceID==cResourceGold)
        gTransportToGoldPos = there;
    else
        gTransportToWoodPos = there;

    //Create a new base.
    string basename="";
    if (resourceID==cResourceGold)
        basename="Gold Base"+kbBaseGetNextID();
    else
        basename="Wood Base"+kbBaseGetNextID();

    int newBaseID=kbBaseCreate(cMyID, basename, there, 40.0);
    if (newBaseID > -1)
    {
        kbBaseSetEconomy(cMyID, newBaseID, true);
        //Set the resource distance limit.
        kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
        //if (ShowAiEcho == true) aiEcho("newResourceBase at location:"+there);
    }

    int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    int towerLimit = kbGetBuildLimit(cMyID, cUnitTypeTower);
    if (numTowers >= towerLimit)
        return(newBaseID);
	
    int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
    int buildTowerPlanID = aiPlanCreate("Build Resource Tower", cPlanBuild);
    if (buildTowerPlanID >= 0)
    {
        aiPlanSetVariableInt(buildTowerPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
        aiPlanSetDesiredPriority(buildTowerPlanID, 100);
        aiPlanSetBaseID(buildTowerPlanID, newBaseID);
        aiPlanSetVariableInt(buildTowerPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(there));
        aiPlanAddUnitType(buildTowerPlanID, builderTypeID, 1, 2, 2);
        aiPlanSetEscrowID(buildTowerPlanID, cEconomyEscrowID);
        aiPlanSetActive(buildTowerPlanID);
    }
    return(newBaseID);
}

//==============================================================================
void setTownLocation(void)
{
    if (ShowAiEcho == true) aiEcho("setTownLocation:");    
    
    static int tcQueryID=-1;
    //If we don't have a query ID, create it.
    if (tcQueryID < 0)
    {
        tcQueryID=kbUnitQueryCreate("TownLocationQuery");
        //If we still don't have one, bail.
        if (tcQueryID < 0)
            return;
        //Else, setup the query data.
        kbUnitQuerySetPlayerID(tcQueryID, cMyID);
        kbUnitQuerySetUnitType(tcQueryID, cUnitTypeAbstractSettlement);
        kbUnitQuerySetState(tcQueryID, cUnitStateAlive);
    }

    //Reset the results.
    kbUnitQueryResetResults(tcQueryID);
    //Run the query.  Be dumb and just take the first TC for now.
    if (kbUnitQueryExecute(tcQueryID) > 0)
    {
        int tcID=kbUnitQueryGetResult(tcQueryID, 0);
        kbSetTownLocation(kbUnitGetPosition(tcID));
    }
}

//==============================================================================
int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1)
{
    if (ShowAiEcho == true) aiEcho("createSimpleMaintainPlan:");    

    //Create the plan name.
    string planName="Military";
    if (economy == true)
        planName="Economy";
    planName=planName+kbGetProtoUnitName(puid)+"Maintain";
   
    int planID=aiPlanCreate(planName, cPlanTrain);
    if (planID < 0)
        return(-1);

    //Economy or Military.
    if (economy == true)
        aiPlanSetEconomy(planID, true);
    else
        aiPlanSetMilitary(planID, true);
    //Unit type.
    aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
    //Number.
    aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, number);
    //If we have a base ID, use it.
    if (baseID >= 0)
    {
        aiPlanSetBaseID(planID, baseID);
        if (economy == false)
            aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
    }

    aiPlanSetActive(planID);

    //Done.
    return(planID);
}

//==============================================================================
bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
    bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1)
{
    if (ShowAiEcho == true) aiEcho("createSimpleBuildPlan:");    

    //Create the right number of plans.
    for (i=0; < number)
    {
        int planID=aiPlanCreate("SimpleBuild"+kbGetUnitTypeName(puid)+" "+number, cPlanBuild);
        if (planID < 0)
            return(false);
        //Puid.
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, puid);
        //Border layers.
        aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 2, kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, baseID)) );
        //Priority.
        aiPlanSetDesiredPriority(planID, pri);
        //Mil vs. Econ.
        aiPlanSetMilitary(planID, military);
        aiPlanSetEconomy(planID, economy);
        //Escrow.
        aiPlanSetEscrowID(planID, escrowID);
        //Builders.
        aiPlanAddUnitType(planID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), numberBuilders, numberBuilders, numberBuilders);
        //Base ID.
        aiPlanSetBaseID(planID, baseID);
		aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 4.0);
        //Go.
        aiPlanSetActive(planID);
    }
}

//==============================================================================
int getSoftPopCap(void) //Calculate our pop limit if we had all houses built
{
    //if (ShowAiEcho == true) aiEcho("getSoftPopCap:");    

    int houseProtoID = cUnitTypeHouse;
    if (cMyCulture == cCultureAtlantean)
        houseProtoID = cUnitTypeManor;
    int houseCount = -1;

    int maxHouses = kbGetBuildLimit(cMyID, houseProtoID);
    int popPerHouse = 10;
    if (cMyCulture == cCultureAtlantean)
        popPerHouse = 20;

		if (maxHouses == -1)
		{
		int Housepop=kbGetPopCapAddition(cMyID, houseProtoID);
		if (cMyCulture == cCultureAtlantean)
		{
        maxHouses = 15; 
		if (Housepop <= 10)
		maxHouses = maxHouses + 5;
		}
        if (cMyCulture != cCultureAtlantean)
		{
        maxHouses = 30; 
		if (Housepop <= 5)
		maxHouses = maxHouses + 10;
		}
        }
    houseCount = kbUnitCount(cMyID, houseProtoID, cUnitStateAlive); // Do not count houses being built

    int retVal = -1;

    retVal = kbGetPopCap();

    retVal = retVal + (maxHouses-houseCount)*popPerHouse;  // Add pop for missing houses

    return(retVal);
}

//==============================================================================
float adjustSigmoid(float var=0.0, float fraction=0.0,  float lowerLimit=0.0, float upperLimit=1.0)
{   // Adjust the variable by fraction amount.  Dampen it for movement near the limits like a sigmoid curve. 
    // A fraction of +.5 means increase it by the lesser of 50% of its original value, or 50% of the space remaining.
    // A fraction of -.5 means decrease it by the lesser of 50% of its original value, or 50% of the distance from the upper limit.

    //if (ShowAiEcho == true) aiEcho("adjustSigmoid:");    

    float spaceAbove = upperLimit - var;

    float adjustRaw = var * fraction;            // .8 at -.5 gives -.4  // .8 at .5 gives 1.2
    float adjustLimit = spaceAbove * fraction;   // .2 at -.5 gives -.1  // .2 at .5 gives .1
    float retVal = 0.0;
    if (fraction > 0) // increasing it
    {
        // choose the smaller of the two
        if (adjustRaw < adjustLimit)
            retVal = var + adjustRaw;
        else
            retVal = var + adjustLimit;
    }
    else  // decreasing it
    {
        // The "smaller" adjustment is the higher number, i.e. -.1 is a smaller adjustment than -.4
        if (adjustRaw < adjustLimit)
            retVal = var + adjustLimit;
        else
            retVal = var + adjustRaw;
    }
    return(retVal);
}

//==============================================================================
void pullBackUnits(int planID = -1, vector retreatPosition = cInvalidVector)
{
    if (ShowAiEcho == true) aiEcho("pullBackUnits:");    
    if (DisallowPullBack == true)
	return;
    int numUnitsInPlan = aiPlanGetNumberUnits(planID, cUnitTypeUnit);
    if (numUnitsInPlan > 0)
    {
        //if (ShowAiEcho == true) aiEcho("*_!_*_!_*_!_pullBackUnits: ");
        //Limited the maximum number of loops
        int min = 0;
        int max = 9;
        
        int unitID = -1;
        static int flipFlop = 0;
        if (flipFlop == 0)
        {
            flipFlop = 1;
            if (numUnitsInPlan > max)
                numUnitsInPlan = max;
            for (i = 0; < numUnitsInPlan)
            {
                //if (ShowAiEcho == true) aiEcho("i = "+i);
                unitID = aiPlanGetUnitByIndex(planID, i);
                if (unitID != -1)
                {
                    //if (ShowAiEcho == true) aiEcho("unitPosition: "+kbUnitGetPosition(unitID));
                    aiTaskUnitMove(unitID, retreatPosition);
                    if (ShowAiEcho == true) aiEcho("pulling unit: "+unitID+" back to retreatPosition: "+retreatPosition);
                }
            }
        }
        else
        {
            flipFlop = 0;
            if (numUnitsInPlan > max)
                min = numUnitsInPlan - max;
            for (i = numUnitsInPlan - 1; >= min)
            {
                //if (ShowAiEcho == true) aiEcho("i = "+i);
                unitID = aiPlanGetUnitByIndex(planID, i);
                if (unitID != -1)
                {
                    //if (ShowAiEcho == true) aiEcho("unitPosition: "+kbUnitGetPosition(unitID));
                    aiTaskUnitMove(unitID, retreatPosition);
                    if (ShowAiEcho == true) aiEcho("pulling unit: "+unitID+" back to retreatPosition: "+retreatPosition);
                }
            }
        }
       
    }
}

//==============================================================================
void keepUnitsWithinRange(int planID = -1, vector retreatPosition = cInvalidVector)
{
    if (ShowAiEcho == true) aiEcho("keepUnitsWithinRange:");    

    int numUnitsInPlan = aiPlanGetNumberUnits(planID, cUnitTypeUnit);
    if (numUnitsInPlan > 0)
    {
        
        if (ShowAiEcho == true) aiEcho("planID: "+planID);
        //Limited the maximum number of loops
        int min = 0;
        int max = 16;
        if (cMyCulture == cCultureAtlantean)
            max = 9;
        
        float engageRange = aiPlanGetVariableFloat(planID, cDefendPlanEngageRange, 0);
        if (ShowAiEcho == true) aiEcho("engageRange: "+engageRange);
        if (engageRange < 35.0)
            engageRange = 25.0;
        if (ShowAiEcho == true) aiEcho("modified engageRange: "+engageRange);
        
        int unitID = -1;
        int actionType = -1;
        vector unitPosition = cInvalidVector;
        float distance = 0.0;
        float modifier = 0.0;
        float minDistance = 0.0;
        float multiplier = 0.0;
        vector directionalVector = cInvalidVector;
        vector desiredPosition = cInvalidVector;
        
        static int flipFlop = 0;
        if (flipFlop == 0)
        {
            flipFlop = 1;
            if (numUnitsInPlan > max)
                numUnitsInPlan = max;
            for (i = 0; < numUnitsInPlan)
            {
                unitID = aiPlanGetUnitByIndex(planID, i);
                if (unitID == -1)
                    continue;
                
                if (kbUnitIsType(unitID, cUnitTypeAbstractTitan) == true)
                    continue;
                
                actionType = kbUnitGetActionType(unitID);
                //if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" has actionType: "+actionType);
                if ((actionType != cActionHandAttack) && (actionType != cActionRangedAttack) && (actionType != cActionLightningAttack))
                    continue;
                
                unitPosition = kbUnitGetPosition(unitID);
                if (ShowAiEcho == true) aiEcho("unitPosition: "+unitPosition);
                distance = xsVectorLength(unitPosition - retreatPosition);
                if (ShowAiEcho == true) aiEcho("distance: "+distance);
                
                modifier = -1.0;
                if (kbUnitIsType(unitID, cUnitTypeAbstractArcher) == true)
                    modifier = -8.0;
                else if (kbUnitIsType(unitID, cUnitTypeThrowingAxeman) == true)
                    modifier = -5.0;
                
                if (distance < engageRange + modifier)
                    continue;
                
                minDistance = 5.0 + distance - engageRange;
                if (minDistance < 10.0)
                    minDistance = 10.0;
                multiplier = minDistance / distance;
                if (ShowAiEcho == true) aiEcho("multiplier: "+multiplier);
                directionalVector = unitPosition - retreatPosition;
                if (ShowAiEcho == true) aiEcho("directionalVector: "+directionalVector);
                desiredPosition = unitPosition - directionalVector * multiplier;
                if (ShowAiEcho == true) aiEcho("desiredPosition: "+desiredPosition);
                aiTaskUnitMove(unitID, desiredPosition);
                if (ShowAiEcho == true) aiEcho("sending unit: "+unitID+" back to position: "+desiredPosition);
            }
        }
        else
        {
            flipFlop = 0;
            if (numUnitsInPlan > max)
                min = numUnitsInPlan - max;
            for (i = numUnitsInPlan - 1; >= min)
            {
                unitID = aiPlanGetUnitByIndex(planID, i);
                if (unitID == -1)
                    continue;
                
                if (kbUnitIsType(unitID, cUnitTypeAbstractTitan) == true)
                    continue;
                
                actionType = kbUnitGetActionType(unitID);
                //if (ShowAiEcho == true) aiEcho("unitID: "+unitID+" has actionType: "+actionType);
                if ((actionType != cActionHandAttack) && (actionType != cActionRangedAttack) && (actionType != cActionLightningAttack))
                    continue;
                
                unitPosition = kbUnitGetPosition(unitID);
                if (ShowAiEcho == true) aiEcho("unitPosition: "+unitPosition);
                distance = xsVectorLength(unitPosition - retreatPosition);
                if (ShowAiEcho == true) aiEcho("distance: "+distance);
                
                modifier = -1.0;
                if (kbUnitIsType(unitID, cUnitTypeAbstractArcher) == true)
                    modifier = -8.0;
                else if (kbUnitIsType(unitID, cUnitTypeThrowingAxeman) == true)
                    modifier = -5.0;
                
                if (distance < engageRange + modifier)
                    continue;
                
                minDistance = 5.0 + distance - engageRange;
                if (minDistance < 10.0)
                    minDistance = 10.0;
                multiplier = minDistance / distance;
                if (ShowAiEcho == true) aiEcho("multiplier: "+multiplier);
                directionalVector = unitPosition - retreatPosition;
                if (ShowAiEcho == true) aiEcho("directionalVector: "+directionalVector);
                desiredPosition = unitPosition - directionalVector * multiplier;
                if (ShowAiEcho == true) aiEcho("desiredPosition: "+desiredPosition);
                aiTaskUnitMove(unitID, desiredPosition);
                if (ShowAiEcho == true) aiEcho("sending unit: "+unitID+" back to position: "+desiredPosition);
            }
        }
        
    }
}

//==============================================================================
int getNumPlayersByRel(bool ally = true)
{
    if (ShowAiEcho == true) aiEcho("**!!**!!** getNumPlayersByRel:");
    if (ally == true)
        if (ShowAiEcho == true) aiEcho("ally");
    else
        if (ShowAiEcho == true) aiEcho("enemy");
        
    int numPlayersByRel = 0;
    int playerID = -1;
    for (playerID = 1; < cNumberPlayers)
    {
        if (playerID == cMyID)
            continue;
        
        if (ally == true)
        {
            if (kbIsPlayerAlly(playerID) == false)
                continue;
        }
        else
        {
            if (kbIsPlayerEnemy(playerID) == false)
                continue;
        }
        
        if ((kbIsPlayerResigned(playerID) == false) && (kbHasPlayerLost(playerID) == false))
        {
            numPlayersByRel = numPlayersByRel + 1;
        }
    }
    if (ShowAiEcho == true) aiEcho("numPlayersByRel: "+numPlayersByRel);
    
    return(numPlayersByRel);
}

//==============================================================================
vector calcMonumentPos(int which=-1)
{
    if (ShowAiEcho == true) aiEcho("calcMonumentPos:");

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
void taskMilUnitTrainAtBase(int baseID = -1)
{
    if (ShowAiEcho == true) aiEcho("taskMilUnitTrainAtBase: "+baseID);
        
    if (baseID == -1)
    {
        if (ShowAiEcho == true) aiEcho("no baseID specified, returning");
        return;
    }
    
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    if ((foodSupply < 150) || (woodSupply < 150) || (goldSupply < 150))
        return;

    vector baseLocation = kbBaseGetLocation(cMyID, baseID);

    int building1ID = cUnitTypeBarracks;
    if (cMyCulture == cCultureGreek)
        building1ID = cUnitTypeStable;
    else if (cMyCulture == cCultureNorse)
        building1ID = cUnitTypeLonghouse;
    else if (cMyCulture == cCultureAtlantean)
        building1ID = cUnitTypeBarracksAtlantean;
    else if (cMyCulture == cCultureChinese)
        building1ID = cUnitTypeStableChinese;		

    int bigBuildingID = cUnitTypeMigdolStronghold;
    if (cMyCulture == cCultureGreek)
        bigBuildingID = cUnitTypeFortress;
    else if (cMyCulture == cCultureNorse)
        bigBuildingID = cUnitTypeHillFort;
    else if (cMyCulture == cCultureAtlantean)
        bigBuildingID = cUnitTypePalace;
    else if (cMyCulture == cCultureChinese)
        bigBuildingID = cUnitTypeCastle;			
    
    int building1NearBase = getNumUnits(building1ID, cUnitStateAlive, -1, cMyID, baseLocation, 30.0);
    int bigBuildingNearBase = getNumUnits(bigBuildingID, cUnitStateAlive, -1, cMyID, baseLocation, 30.0);
    
    bool militaryBuilding1Available = false;
    bool bigBuildingAvailable = false;
    
    if (building1NearBase > 0)
    {
        int militaryBuilding1ID = findUnitByIndex(building1ID, 0, cUnitStateAlive, -1, cMyID, baseLocation, 30.0);
        if (militaryBuilding1ID > 0)
            militaryBuilding1Available = true;
    }
  
    if (bigBuildingNearBase > 0)
    {
        int bigBuilding1ID = findUnitByIndex(bigBuildingID, 0, cUnitStateAlive, -1, cMyID, baseLocation, 30.0);
        if (bigBuilding1ID > 0)
            bigBuildingAvailable = true;
    }
    
    int buildingToUse = -1;
    bool override = false;
    int hero1ID = -1;
    int hero2ID = -1;
    int settlementIDNearBase = findUnitByIndex(cUnitTypeAbstractSettlement, 0, cUnitStateAlive, -1, cMyID, baseLocation, 15.0);
    if (ShowAiEcho == true) aiEcho("settlementIDNearBase: "+settlementIDNearBase);
    if ((settlementIDNearBase != -1) && (cMyCulture == cCultureGreek))
    {
        if (cMyCiv == cCivZeus)
        {
            hero1ID = cUnitTypeHeroGreekJason;
            hero2ID = cUnitTypeHeroGreekOdysseus;
        }
        else if (cMyCiv == cCivPoseidon)
        {
            hero1ID = cUnitTypeHeroGreekTheseus;
            hero2ID = cUnitTypeHeroGreekHippolyta;
        }
        else if (cMyCiv == cCivHades)
        {
            hero1ID = cUnitTypeHeroGreekAjax;
            hero2ID = cUnitTypeHeroGreekChiron;
        }
        int numHero1 = kbUnitCount(cMyID, hero1ID, cUnitStateAliveOrBuilding);
        int numHero2 = kbUnitCount(cMyID, hero2ID, cUnitStateAliveOrBuilding);
    }
    
    if ((militaryBuilding1Available == false) && (bigBuildingAvailable == false))
    {
        if ((settlementIDNearBase != -1) && (cMyCulture != cCultureAtlantean))
        {
            override = true;
            if (ShowAiEcho == true) aiEcho("setting override = true");
        }
        else
        {
            if (ShowAiEcho == true) aiEcho("No building available, returning");
            return;
        }
    }
    else if ((militaryBuilding1Available == true) && (bigBuildingAvailable == true))
    {
        int randomBuilding = aiRandInt(4);
        if (((cMyCulture == cCultureNorse) && (randomBuilding < 2))
         || ((cMyCulture != cCultureNorse) && (randomBuilding < 3) && (kbGetAge() < cAge4))
         || ((cMyCulture != cCultureNorse) && (randomBuilding < 2) && (kbGetAge() >= cAge4)))
        {
            buildingToUse = militaryBuilding1ID;
        }
        else
        {
            buildingToUse = bigBuilding1ID;
        }
    }
    else if (militaryBuilding1Available == true)
    {
        buildingToUse = militaryBuilding1ID;
    }
    else if (bigBuildingAvailable == true)
    {
        if ((settlementIDNearBase != -1) && (cMyCulture == cCultureGreek))
        {
            if ((numHero1 < 1) || (numHero2 < 1))
            {
                override = true;
                if (ShowAiEcho == true) aiEcho("setting override = true");
            }
        }
        
        if (override == false)
            buildingToUse = bigBuilding1ID;
    }
    else
    {
        //shouldn't happen anyway
        if (ShowAiEcho == true) aiEcho("strange, no building available, returning");
        return;
    }
    
    int puid = -1;

    if (override == true)
    {
        if (cMyCulture == cCultureEgyptian)
        {
            puid = cUnitTypePriest;
        }
        else if (cMyCulture == cCultureGreek)
        {
            if (numHero1 < 1)
            {
                puid = hero1ID;
            }
            else
            {
                if (numHero2 < 1)
                {
                    puid = hero2ID;
                }
            }
        }
        else if (cMyCulture == cCultureNorse)
        {
            puid = cUnitTypeUlfsark;
        }
        
        buildingToUse = settlementIDNearBase;
    }
    
    int randomUnit = aiRandInt(4);
    
    if (buildingToUse == militaryBuilding1ID)
    {
        if (cMyCulture == cCultureGreek)
        {
            puid = cUnitTypeHippikon;
        }
        else if (cMyCulture == cCultureEgyptian)
        {
            puid = cUnitTypeSpearman;
        }
        else if (cMyCulture == cCultureNorse)
        {
            if (randomUnit < 2)
                puid = cUnitTypeThrowingAxeman;
            else
                puid = cUnitTypeRaidingCavalry;
        }
        else if (cMyCulture == cCultureAtlantean)
        {
            puid = cUnitTypeSwordsman;
        }
    }
    else if (buildingToUse == bigBuilding1ID)
    {
        if (cMyCulture == cCultureGreek)
        {
            if (kbGetAge() > cAge3)
            {
                if (cMyCiv == cCivZeus)
                    puid = cUnitTypeMyrmidon;
                else if (cMyCiv == cCivHades)
                    puid = cUnitTypeCrossbowman;
                else if (cMyCiv == cCivPoseidon)
                    puid = cUnitTypeHetairoi;
            }
            else
            {
                puid = cUnitTypePetrobolos;
            }
        }
        else if (cMyCulture == cCultureEgyptian)
        {
            if (randomUnit > 1)
            {
                puid = cUnitTypeChariotArcher;
            }
            else
            {
                puid = cUnitTypeCamelry;
            }
        }
        else if (cMyCulture == cCultureNorse)
        {
            if (randomUnit > 1)
            {
                puid = cUnitTypeJarl;
            }
            else
            {
                puid = cUnitTypeHuskarl;
            }
        }
        else if (cMyCulture == cCultureAtlantean)
        {
            if ((kbGetAge() > cAge3) && (randomUnit > 0))
            {
                puid = cUnitTypeRoyalGuard;
            }
            else
            {
                puid = cUnitTypeTridentSoldier;
            }
        }
        else if (cMyCulture == cCultureChinese)
        {
            if ((kbGetAge() > cAge3) && (randomUnit > 0))
            {
                puid = cUnitTypeFireLance;
            }
            else
            {
                puid = cUnitTypeWarChariot;
            }
        }		
    }
    else
    {
        if (override == false)
        {
            //shouldn't happen anyway
            if (ShowAiEcho == true) aiEcho("strange building ID: "+buildingToUse+", returning");
            return;
        }
    }
    
    if (puid == -1)
    {
        if (ShowAiEcho == true) aiEcho("puid == -1, returning");
        return;
    }
    
    int numUnitsBeingTrainedNearBase = getNumUnits(puid, cUnitStateBuilding, -1, cMyID, baseLocation, 30.0);
    if (numUnitsBeingTrainedNearBase < 1)
    {
        //train a unit via aiTaskUnitTrain
        aiTaskUnitTrain(buildingToUse, puid);
        if (ShowAiEcho == true) aiEcho("Trying to train a unit with puid: "+puid+" at building with ID: "+buildingToUse);
    }
    else
    {
        if (ShowAiEcho == true) aiEcho("a unit with puid: "+puid+" is already being trained near baseID: "+baseID);
    }
}