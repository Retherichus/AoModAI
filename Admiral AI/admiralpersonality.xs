//==============================================================================
// ADMIRAL X
// admiralpersonality.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// set personality of admiral. 
//==============================================================================

//==============================================================================
// perDecidePersonality
//==============================================================================
void persDecidePersonality(void)
{

// This AI randomly chooses from one of the six other personalities, and sets the 
// variables accordingly.
   int choice = -1;
   choice = aiRandInt(6);     // 0..5
//   choice = 1;
   switch(choice)
   {
      case 0:  // Balanced
      {
         OUTPUT("Choosing personality:  Balanced (Standard)", INFO);
         cvRushBoomSlider = 0.0;            
         cvMilitaryEconSlider = 0.0;
         cvOffenseDefenseSlider = 0.0;
         cvSliderNoise = 0.2;    
         break;
      }
      case 1:  // Aggressive Rusher (attacker)
      {
         OUTPUT("Choosing personality:  Aggressive Rusher (Attacker)", INFO);
         cvRushBoomSlider = 0.9;
         cvMilitaryEconSlider = 0.9;
         cvOffenseDefenseSlider = 0.9;
         cvSliderNoise = 0.2;    
         break;
      }
      case 2:  // Aggressive Boomer (conqueror)
      {
         OUTPUT("Choosing personality:  Aggressive Boomer (Conqueror)", INFO);
         cvRushBoomSlider = -0.9;
         cvMilitaryEconSlider = 0.3;
         cvOffenseDefenseSlider = 0.9;
         cvSliderNoise = 0.2; 
         break;
      }
      case 3:  // Economic Boomer (builder)
      {
         OUTPUT("Choosing personality:  Economic Boomer (Builder)", INFO);
         cvRushBoomSlider = -0.9;
         cvMilitaryEconSlider = -0.9;
         cvOffenseDefenseSlider = 0.0;
         cvSliderNoise = 0.2; 
         break;
      }
      case 4:  // Defensive Rusher (defender)
      {
         OUTPUT("Choosing personality:  Defensive Rusher (Defender)", INFO);
         cvRushBoomSlider = 0.9;
         cvMilitaryEconSlider = 0.9;
         cvOffenseDefenseSlider = -0.9;
         cvSliderNoise = 0.2;
         break;
      }
      case 5:  // Defensive Boomer (protector)
      {
         OUTPUT("Choosing personality:  Defensive Boomer (Protector)", INFO);
         cvRushBoomSlider = -0.9;
         cvMilitaryEconSlider = 0.3;
         cvOffenseDefenseSlider = -0.9;
         cvSliderNoise = 0.1; 
         break;
      }
   }


   OUTPUT("In setParameters, sliders are...", INFO);
   OUTPUT("RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider, INFO);

}

//==============================================================================
// persWantForwardBase 
// Decide if we want to build a forward base depending on personality
//==============================================================================
bool persWantForwardBase()
{
	OUTPUT("persWantForwardBase:", TRACE);

   static bool bDecided=false;
   static bool ret=false;
	if ( bDecided )
	   return(ret);

	// TODO: more civ-specific.
	// always build forward base on gold rush.
	if (cRandomMapName == "gold rush")
	{
      ret=true;
	}
	else if(cMyCulture == cCultureNorse || cMyCulture == cCultureAtlantean)
	{
	   if(cvRushBoomSlider > 0.6 && cvMilitaryEconSlider > 0.6 && cvOffenseDefenseSlider > 0.7)
		   ret=true;
		else if(aiRandInt(6)==0)
			ret=true;
		else
			ret=false;
	}
	else if(cMyCulture == cCultureEgyptian || cMyCulture == cCultureGreek)
	{
	   if(cvRushBoomSlider > 0.8 && cvMilitaryEconSlider > 0.8 && cvOffenseDefenseSlider > 0.9)
		   ret=true;
		else if(aiRandInt(8)==0)
			ret=true;
		else
			ret=false;
	}

	bDecided=true;
	return(ret);
}

