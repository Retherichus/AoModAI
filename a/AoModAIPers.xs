//==============================================================================
// AoMod AI
// AoModAIPers.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// set personality of AoMod. 
//==============================================================================


//==============================================================================
void persDecidePersonality(void)
{
    if (ShowAiEcho == true) aiEcho("persDecidePersonality:");

// This AI randomly chooses from one of the six other personalities, and sets the 
// variables accordingly.
    int choice = -1;
    choice = aiRandInt(6);     // 0..5
    
//Test start TODO: disable this part once the AI works as espected
// choice = 1;
// choice = 5;
//Test end

    switch(choice)
    {
        case 0:  // Defensive Boomer (protector)
        {
            aiEcho("Choosing personality:  Defensive Boomer (Protector)");
            cvRushBoomSlider = -0.9;
            cvMilitaryEconSlider = 0.3;
            cvOffenseDefenseSlider = -0.9;
            cvSliderNoise = 0.1;
            break;
        }
        case 1:  // Defensive Rusher (defender)
        {
            aiEcho("Choosing personality:  Defensive Rusher (Defender)");
            cvRushBoomSlider = 0.9;
            cvMilitaryEconSlider = 0.9;
            cvOffenseDefenseSlider = -0.9;
            cvSliderNoise = 0.2;
            break;
        }
        case 2:  // Economic Boomer (builder)
        {
            aiEcho("Choosing personality:  Economic Boomer (Builder)");
            cvRushBoomSlider = -0.9;
            cvMilitaryEconSlider = -0.7;
            cvOffenseDefenseSlider = 0.0;
            cvSliderNoise = 0.2; 
            break;
        }
        case 3:  // Balanced
        {
            aiEcho("Choosing personality:  Balanced (Standard)");
            cvRushBoomSlider = 0.0;            
            cvMilitaryEconSlider = 0.0;
            cvOffenseDefenseSlider = 0.0;
            cvSliderNoise = 0.2;
            break;
        }
        case 4:  // Aggressive Boomer (conqueror)
        {
            aiEcho("Choosing personality:  Aggressive Boomer (Conqueror)");
            cvRushBoomSlider = -0.9;
            cvMilitaryEconSlider = 0.3;
            cvOffenseDefenseSlider = 0.9;
            cvSliderNoise = 0.2; 
            break;
        }
        case 5:  // Aggressive Rusher (attacker)
        {
            aiEcho("Choosing personality:  Aggressive Rusher (Attacker)");
            cvRushBoomSlider = 0.9;
            cvMilitaryEconSlider = 0.9;
            cvOffenseDefenseSlider = 0.9;
            cvSliderNoise = 0.2;    
            break;
        }
    }

    if (ShowAiEcho == true) aiEcho("RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);

}
