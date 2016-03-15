// Borrowed code from the Stardard AI to support a more stable WoodBase.

float vec2LenSq(vector vec2 = cInvalidVector)
{
	return((xsVectorGetX(vec2)*xsVectorGetX(vec2))+(xsVectorGetZ(vec2)*xsVectorGetZ(vec2)));
}

float vec2Cross(vector v0 = cInvalidVector, vector v1 = cInvalidVector)
{
	return(xsVectorGetX(v0)*xsVectorGetZ(v1) - xsVectorGetZ(v0)*xsVectorGetX(v1));
}

vector movePointToPoint(vector v0= cInvalidVector, vector v1 = cInvalidVector, float percentage = -1.0)
{
	float x = xsVectorGetX(v0);
	float z = xsVectorGetZ(v0);
	return(xsVectorSet(x + percentage*(xsVectorGetX(v1)-x),0.0,z + percentage*(xsVectorGetZ(v1)-z)));
}



bool vec2Equal(vector v0 = cInvalidVector, vector v1 = cInvalidVector)
{
	if(xsVectorGetX(v0)!=xsVectorGetX(v1))
	{
		return(false);
	}
	if(xsVectorGetZ(v0)!=xsVectorGetZ(v1))
	{
		return(false);
	}
	return(true);
}


bool pointInRangeOfPoint(vector v0 = cInvalidVector, vector v1 = cInvalidVector, float range = -1.0)
{
	return(vec2LenSq(v0-v1)<=range*range);
}

int getNumberUnitsInArea(int areaID =-1,int unitType =-1)
{
	int num = kbAreaGetNumberUnits(areaID);
	int retNum = 0;
	for(i=0;<num)
	{
		if(kbUnitIsType(kbAreaGetUnitID(areaID,i),unitType))
		{
			retNum++;
		}
	}
	return(num);
}

int findClosestAreaWithUnits(int areaID = -1,int type=-1, int unitType = -1, int numUnits=-1, int recursion = 3)
{
	aiEcho("Looking around area: "+areaID);
	vector position   = kbAreaGetCenter(areaID);
	int numBorderAreas   = kbAreaGetNumberBorderAreas(areaID);
	int borderArea   = -1;
	int closestArea   = -1;
	int numRequiredUnits = -1;
	int num  = -1;
	float distance   = 0;
	float lastDistance   = 999999;
	// Check for the closest
	for(i=0;< numBorderAreas)
	{
		borderArea = kbAreaGetBorderAreaID(areaID,i);
		if(getNumberUnitsInArea(borderArea,unitType)>=numUnits&&kbAreaGetType(borderArea)==type)
		{
			distance = vec2LenSq(position-kbAreaGetCenter(borderArea));
			if(distance<lastDistance)
			{
				lastDistance = distance;
				closestArea  = borderArea;
			}
		}
	}
	if(closestArea != -1)
	{
		return(closestArea);
	}
	if(recursion!=0)
	{
		for(i=0;< numBorderAreas)
		{
			borderArea = findClosestAreaWithUnits(kbAreaGetBorderAreaID(areaID,i),type,unitType,numUnits,recursion-1);
			distance   = vec2LenSq(position-kbAreaGetCenter(borderArea));
			if(distance<lastDistance)
			{
				lastDistance = distance;
				closestArea  = borderArea;
			}
		}
	}
	return(closestArea);
}