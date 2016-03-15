//==============================================================================
// ADMIRAL X
// admiralbasics.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// Basic functions and definitions
//==============================================================================

//==============================================================================

// Set this to true to let the admiral explore other islands. 
// This is a potential reason for the crashes
// Set this to false to disallow exploration of other islands. This may avoid
// the crashes but also means less strength of admiral...
// This is again nothing but a wild guess. If the game doesn't crash if this
// variable is set to false, I will have to rework the exploration part...
extern bool cvDoExploreOtherIslands = true;

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
extern bool    cvDoAutoSaves = true;


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

//==============================================================================
// Output message types
extern const int ALWAYS = 0;
extern const int FAILURE=1;
extern const int TEST=2;
extern const int ECONWARN=3;
extern const int MILWARN=4;
extern const int INFO=5;
extern const int GPINFO=6;
extern const int MAPSPEC=7;
extern const int MILINFO=8;
extern const int ECONINFO=9;
extern const int TRACE=10;

extern const int warnLevel=8;

//==============================================================================
// OUTPUT --- prints the given message to the debug window, if
//            the specified type is currently switched on.
//            This way, selective output is possible
//==============================================================================
void OUTPUT(string text="", int type=-1)
{
   string prefix="";
   if ( type == ALWAYS )
      prefix="";
   if ( type == FAILURE )
      prefix="FAILURE: ";
   else if ( type == ECONINFO )
      prefix="ECONINFO: ";
   else if ( type == ECONWARN )
      prefix="ECONWARN: ";
   else if ( type == GPINFO )
      prefix="GPINFO: ";
   else if ( type == MILINFO )
      prefix="MILINFO: ";
   else if ( type == MILWARN )
      prefix="MILWARN: ";
   else if ( type == TEST )
      prefix="TEST: ";
   else if ( type == MAPSPEC )
      prefix="MAP: ";
   else if ( type == INFO )
      prefix="INFO: ";

   if ( type <= warnLevel )
      aiEcho(prefix+text);
}

//==============================================================================
// getAreaByAreaGroup --- this is such shit, but there is no other possibility
//                        as far as I can see :-(
//==============================================================================
int getAreaGroupByArea(int areaID=-1)
{
   vector loc = kbAreaGetCenter(areaID);
   return (kbAreaGroupGetIDByPosition(loc));
}

// *****************************************************************************
//
// configQuery
//
// Sets up all the non-default parameters so you can config a query on a single call.
// Query must be created prior to calling, and the results reset and the query executed
// after the call.
//
// ***************************************************************************** 
bool  configQuery( int queryID = -1, int unitType = -1, int action = -1, int state = -1, int player = -1, vector center = vector(-1,-1,-1), bool sort = false, float radius = -1 )
{

   if ( queryID == -1)
   {
      OUTPUT("Invalid query ID", FAILURE);
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

   if (center != vector(-1,-1,-1))
   {
      kbUnitQuerySetPosition(queryID, center);
      if (sort == true)
         kbUnitQuerySetAscendingSort(queryID, true);
      if (radius != -1)
         kbUnitQuerySetMaximumDistance(queryID, radius);
   }
   return(true);
}

// *****************************************************************************
//
// configQueryRelation
//
// Sets up all the non-default parameters so you can config a query on a single call.
// Query must be created prior to calling, and the results reset and the query executed
// after the call.
// Unlike configQuery(), this uses the PLAYER RELATION rather than the player number
//
// ***************************************************************************** 
bool  configQueryRelation( int queryID = -1, int unitType = -1, int action = -1, int state = -1, int playerRelation = -1, vector center = vector(-1,-1,-1), bool sort = false, float radius = -1 )
{
   if ( queryID == -1)
   {
      OUTPUT("Invalid query ID", FAILURE);
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

   if (center != vector(-1,-1,-1))
   {
      kbUnitQuerySetPosition(queryID, center);
      if (sort == true)
         kbUnitQuerySetAscendingSort(queryID, true);
      if (radius != -1)
         kbUnitQuerySetMaximumDistance(queryID, radius);
   }
   return(true);
}

//==============================================================================
// equal --- true if the given vectors are equal
//==============================================================================
bool equal(vector left=cInvalidVector, vector right=cInvalidVector)
{
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

//==============================================================================
// guessEnemyLocation --- returns the assumed location of the enemy town
// TODO: currently works for 1v1. Bad results for 1v2 (every even number of
// enemies)
//==============================================================================
vector guessEnemyLocation()
{
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
// findUnit
// Will find a random unit of the given playerID
//==============================================================================
int findUnit(int unitTypeID=-1, int state=cUnitStateAlive,
             int action=-1, int playerID=cMyID)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("randFindUnitQuery");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
      configQuery(unitQueryID, unitTypeID, action, state, playerID);
   else
      return(-1);

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);
   for (i=0; < numberFound)
      return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));
   return(-1);
}

//==============================================================================
// isOnMyIsland 
//==============================================================================
bool isOnMyIsland(vector there=cInvalidVector)
{
   //Get our initial location.
   vector here=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   int myAreaGroupID = kbAreaGroupGetIDByPosition(here);
   int islandGroupID=kbAreaGroupGetIDByPosition(there);
   return(myAreaGroupID==islandGroupID);
}

bool hasWaterNeighbor(int areaID = -1)    // True if the test area has a water area neighbor
{
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
      OUTPUT("    "+areaID+" has a water neighbor.", ECONINFO);

   return(hasWater);
}


//==============================================================================
// verifyVinlandsagaBase - verify that this area borders water, find another if it doesn't.
//==============================================================================
int verifyVinlandsagaBase(int goalAreaID = -1, int recurseCount = 3 )
{
   OUTPUT("verifyVinlandsagaBase:", TRACE);

   int newAreaID = goalAreaID;      // New area will be the one we use.  By default,
                                    // we'll start with the one passed to us.
   bool done = false;               // Set true when we find an acceptable one
   int index = -1;                  // Which number are we checking
   int areaCount = -1;              // How many areas to search
   int testArea = -1;

   if (recurseCount == 3)     // 3 more levels allowed
      OUTPUT("***** Beginning verifyVinlandsagaBase "+goalAreaID, TEST);
   else if (recurseCount == 2)
      OUTPUT("    "+goalAreaID, TEST);
   else if (recurseCount == 1)
      OUTPUT("        "+goalAreaID, TEST);
   else if (recurseCount == 0)
      OUTPUT("           "+goalAreaID, TEST);

   if (hasWaterNeighbor(goalAreaID) == true)    // Simple case
   {
      OUTPUT("Target area "+goalAreaID+" has a water neighbor...using it.", TEST);
      return(goalAreaID);
   }
   int recurseLevel = 0;
   if (recurseCount > 0)
   {
      for( recurseLevel=0; < recurseCount)
      {
         OUTPUT("Area "+goalAreaID+" has "+kbAreaGetNumberBorderAreas(goalAreaID)+" neighbors.", ECONINFO);
         OUTPUT("Testing "+(recurseLevel+1)+" layers around area "+goalAreaID, ECONINFO);
         // Test each area that borders each border area.  
         for (index=0; < kbAreaGetNumberBorderAreas(goalAreaID))  // Get each border area
         {
            testArea = kbAreaGetBorderAreaID(goalAreaID, index);
            if ( verifyVinlandsagaBase(testArea, recurseLevel) > 0)
            {
               return(testArea);
            }
         }
//         if (recurseLevel == 2)
//            breakpoint;
      }
   }


   if (recurseCount == 3)     // Sigh, just fail and return -1.
      OUTPUT("Couldn't find a water-bordered area.", ECONINFO);
   return(-1);
}

//==============================================================================
// some trigonometric functions stolen from The Void RMS by Wolfenhex
// Many thanks to Wolfenhex for providing these functions
// His RMS can be found here:
// http://aom.heavengames.com/downloads/showfile.php?fileid=1377
//==============================================================================
extern float PI = 3.141592;

float _pow(float n = 0,int x = 0) {
  float r = n;
  for(i = 1; < x) {
    r = r * n;
  }
  return (r);
}

float _atan(float n = 0) {
  float m = n;
  if(n > 1) m = 1.0 / n;
  if(n < -1) m = -1.0 / n;
  float r = m;
  for(i = 1; < 100) {
    int j = i * 2 + 1;
    float k = _pow(m,j) / j;
    if(k == 0) break;
    if(i % 2 == 0) r = r + k;
    if(i % 2 == 1) r = r - k;
  }
  if(n > 1 || n < -1) r = PI / 2.0 - r;
  if(n < -1) r = 0.0 - r;
  return (r);
}

float _atan2(float z = 0,float x = 0) {
  if(x > 0) return (_atan(z / x));
  if(x < 0) {
    if(z < 0) return (_atan(z / x) - PI);
    if(z > 0) return (_atan(z / x) + PI);
    return (PI);
  }
  if(z > 0) return (PI / 2.0);
  if(z < 0) return (0.0 - (PI / 2.0));
  return (0);
}

float _fact(float n = 0) {
  float r = 1;
  for(i = 1; <= n) {
    r = r * i;
  }
  return (r);
}

float _cos(float n = 0) {
  float r = 1;
  for(i = 1; < 100) {
    int j = i * 2;
    float k = _pow(n,j) / _fact(j);
    if(k == 0) break;
    if(i % 2 == 0) r = r + k;
    if(i % 2 == 1) r = r - k;
  }
  return (r);
}

float _sin(float n = 0) {
  float r = n;
  for(i = 1; < 100) {
    int j = i * 2 + 1;
    float k = _pow(n,j) / _fact(j);
    if(k == 0) break;
    if(i % 2 == 0) r = r + k;
    if(i % 2 == 1) r = r - k;
  }
  return (r);
}
//==============================================================================
// end trigonometric functions by wolfenhex
//==============================================================================

//==============================================================================
// findForwardBasePos -- 
//==============================================================================
vector findForwardBasePos()
{
   OUTPUT("findForwardBase:", TRACE);
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
      rnd=rnd/20.0;
      float p=PI*-0.33;
      p=p+(PI*0.33*rnd);
      float q = _atan2(xsVectorGetZ(normalized), xsVectorGetX(normalized));
      float c = _cos(q+p);
      float s = _sin(q+p);
      float x = xsVectorGetX(enemyPos) + (c * radius);
      float z = xsVectorGetZ(enemyPos) + (s * radius);
      OUTPUT("findForwardBase: x="+x, TEST);
      OUTPUT("findForwardBase: z="+z, TEST);
      forwardBasePos = xsVectorSetX(forwardBasePos, x);
      forwardBasePos = xsVectorSetZ(forwardBasePos, z);

      // we do not need to test AGID's if we are on a land map
      if(gTransportMap==false)
      {
         return(forwardBasePos);
      }

      int enemyAGID=kbAreaGroupGetIDByPosition(enemyPos);
      int i = -1;
      vector towardHim = enemyPos - forwardBasePos;
      towardHim = towardHim / 20;    // 5% of distance from forward base to him
      bool success = false;
      int forwardAGID=-1;

      for (i=0; <18)    // Keep testing until areaGroups match
      {
         forwardAGID = kbAreaGroupGetIDByPosition(forwardBasePos);
         if (enemyAGID == forwardAGID)
         {
            success = true;

	    // ensure that we get an area at coast.
	    int areaID=kbAreaGetIDByPosition(forwardBasePos);
	    areaID=verifyVinlandsagaBase(areaID);
	    forwardBasePos=kbAreaGetCenter(areaID);
            break;
         }
         else
         {
            forwardBasePos = forwardBasePos + towardHim;   // Try a bit closer
         }
      }
      if (success == false)
      {
         forwardBasePos=cInvalidVector;
      }
   }
   return(forwardBasePos);
}

//==============================================================================
// getPlayerForIsland -- 
//==============================================================================
int getPlayerForIsland(int AGID=-1)
{
   int hasMost=-1;
   int max=0;
   int cur=0;

   for(i=0; < cNumberPlayers)
   {
      cur=kbUnitCount(i, -1, cUnitStateAlive);
      if(cur > max)
      {
         max=cur;
	 hasMost=i;
      }
   }
   return(hasMost);
}
