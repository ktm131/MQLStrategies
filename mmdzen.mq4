//+------------------------------------------------------------------+
//|                                                       mmdzen.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define SLIPPAGE              5
#define NO_ERROR              1
#define AT_LEAST_ONE_FAILED   2

extern int button_size = 1;
int xSize;
int ySize;
int hideAllPosition = 0;

bool opened;
int ticket;
double priceWhenOpen;
double priceWhenClose;
bool openPosition;
bool closePosition;
double maxLoss;
double slip;
double openPrice;
double pipsStopLoss;
double risk;
datetime lastbar;
double points;

string openOn = "OpenDay";
bool trade = false;
bool close = false;
bool up = true;
double size;
bool openNow;

string openDayOption = "Low";
double openDayLow;
double openDayHigh;

string zonerOption = "High";
datetime zonerTime; 
double zonerPrice;
double zonerLow;
double zonerHigh;
double zonerPivot;

double userLevel = 0;

bool retest = false;
string retestOption;
double retestLevel = 0;
string retestCloud;
string retestCloudOption;

string cloud = "Red";
string cloudOption = "Top";
double red0,red1,redTop,redLow,orange0,orange1,orangeTop,orangeLow,blue0,blue1,blueTop,
blueLow,green0,green1,greenTop,greenLow,violet0,violet1,violetTop,violetLow,yellow0,yellow1,yellowTop,yellowLow;

string envelopesOption = "m5Low";
bool envelopesUp = false;

int openedDirection;
double openedPrice;
string openedOption;
string openedLevel;
string openedCloud;
datetime openCandleTime;

int selectedTicket = 0;
double priceWhenCloseSelected = 0;


string slOption = "sizeAndPips";


string setOpenButtonName = "setOpenButton";
string setCloseButtonName = "setCloseButton";
string openDayButtonName = "openDayButton";
string zonerButtonName = "zonerButton";
string cloudButtonName = "cloudButton";
string levelButtonName = "levelButton";
string envelopesButtonName = "envelopesButton";
string buyButtonName = "buyButton";
string sellButtonName = "sellButton";

string openDayLowButtonName = "openDayLowButton";
string openDayHighButtonName = "openDayHighButton";

string zonerLowButtonName = "zonerLowButton";
string zonerPivotButtonName = "zonerPivotButton";
string zonerHighButtonName = "zonerHighButton";

string cloudRedButtonName = "cloudRedButton";
string cloudOrangeButtonName = "cloudOrangeButton";
string cloudBlueButtonName = "cloudBlueButton";
string cloudGreenButtonName = "cloudGreenButton";
string cloudVioletButtonName = "cloudVioletButton";
string cloudYellowButtonName = "cloudYellowButton";
string cloudHighButtonName = "cloudHighButton";
string cloudLowButtonName = "cloudLowButton";

string levelInputName = "levelInput";
string levelLabelName = "levelLbl";

string m5LowDownButtonName = "m5LowDownButton";
string m5LowUpButtonName = "m5LowUpButton";
string m5HighDownButtonName = "m5HighDownButton";
string m5HighUpButtonName = "m5HighUpButton";
string h1LowDownButtonName = "h1LowDownButton";
string h1LowUpButtonName = "h1LowUpButton";
string h1HighDownButtonName = "h1HighDownButton";
string h1HighUpButtonName = "h1HighUpButton";

string slLabelName = "slLabel";
string slInputName = "slInput";

string riskLabelName = "riskLabel";
string riskInputName = "riskInput";

string slipLabelName = "slipLabel";
string slipInputName = "slipInput";

string openOrderLabelName= "openOrderLabel";
string closeOrderLabelName= "closeOrderLabel";

string stoplossSizeButton = "stoplossSizeButton";
string stoplossRiskButton = "stoplossRiskButton";

string sizeLabel = "sizeLabel";
string sizeEdit = "sizeEdit";
string pointsLabel = "pointsLabel";
string pointsEdit = "pointsEdit";

string riskLabel = "riskLabel";
string riskEdit = "riskEdit";
string pointsLabel1 = "pointsLabel1";
string pointsEdit1 = "pointsEdit1";

string retestButtonName = "retestButton";
string retestLabelName = "retestLabel";

string openOrderBuyButtonName = "openOrderBuyNameButton"; 
string openOrderSellButtonName = "openOrderSellNameButton"; 

string hideAllButtonName = "hideAllButton";
string closeAllButtonName = "closeAllButton";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     initData();
   
//---
   return(INIT_SUCCEEDED);
  }
  
void initData()
{
   opened = false;
   ticket = 0;
   priceWhenOpen = 0;
   priceWhenClose = 0;
   openPosition = false;
   closePosition = false;
   maxLoss = 0;
   slip = 0;
   openPrice = 0;
   pipsStopLoss = 0;
   risk = 10;
   openOn = "OpenDay";
   trade = false;
   close = false;
   up = true;
   openDayOption = "Low";
   openDayLow = 0;
   openDayHigh = 0;
   zonerOption = "High";
   zonerPrice = 0;
   zonerLow = 0;
   zonerHigh = 0;
   zonerPivot = 0;
   userLevel = 0;
   cloud = "Red";
   cloudOption = "Top";
   size = 0.1;
   points = 1000;
   retest = false;
   openNow = false;
   selectedTicket = 0;
   priceWhenCloseSelected = 0;
   
   xSize = 50 * button_size;
   ySize = 20 * button_size;
   ShowButtons();
   
   ObjectDelete(openOrderLabelName);
   ObjectDelete(closeOrderLabelName);
   ObjectDelete(retestLabelName);
   ZonerSubOptionsHide();
   CloudSubOptionsHide();
   LevelSubOptionsHide();
   
   CalculateClouds();
   CalculateOpenDayLevels();
   
   lastbar=Time[1];
   
   hideAllOrders();
   ShowAllOrders();
}

void ShowButtons()
{
   int xStart = 50;
   int yStart = 20;

   ObjectCreate(0,openDayButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,openDayButtonName,OBJPROP_TEXT,"Open");
   ObjectSetInteger(0,openDayButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,openDayButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,openDayButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,openDayButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,openDayButtonName,OBJPROP_STATE,true);
   xStart += xSize;
   
   
   OpenDaySubOptions();
   
   ObjectCreate(0,zonerButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,zonerButtonName,OBJPROP_TEXT,"Zoner");
      ObjectSetInteger(0,zonerButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,zonerButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,zonerButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,zonerButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,zonerButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,cloudButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudButtonName,OBJPROP_TEXT,"Cloud");
      ObjectSetInteger(0,cloudButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,levelButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,levelButtonName,OBJPROP_TEXT,"Level");
      ObjectSetInteger(0,levelButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,levelButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,levelButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,levelButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,levelButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,envelopesButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,envelopesButtonName,OBJPROP_TEXT,"ENV");
   ObjectSetInteger(0,envelopesButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,envelopesButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,envelopesButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,envelopesButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,envelopesButtonName,OBJPROP_STATE,false);
   xStart += xSize;
      
   ObjectCreate(0,buyButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,buyButtonName,OBJPROP_TEXT,"BUY");
      ObjectSetInteger(0,buyButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,buyButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,buyButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,buyButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,buyButtonName,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,buyButtonName,OBJPROP_BGCOLOR,clrGreen); 
   ObjectSetInteger(0,buyButtonName,OBJPROP_STATE,true);
   xStart += xSize;
   
   ObjectCreate(0,sellButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,sellButtonName,OBJPROP_TEXT,"SELL");
      ObjectSetInteger(0,sellButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,sellButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,sellButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,sellButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,sellButtonName,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,sellButtonName,OBJPROP_BGCOLOR,clrRed);
   ObjectSetInteger(0,sellButtonName,OBJPROP_STATE,false);  
   xStart += xSize;
   
   ObjectCreate(0,setOpenButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,setOpenButtonName,OBJPROP_TEXT,"OPEN");
      ObjectSetInteger(0,setOpenButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,setOpenButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,setOpenButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,setOpenButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,setOpenButtonName,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,setOpenButtonName,OBJPROP_BGCOLOR,clrBlue);
   ObjectSetInteger(0,setOpenButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,setCloseButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,setCloseButtonName,OBJPROP_TEXT,"CLOSE");
      ObjectSetInteger(0,setCloseButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,setCloseButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,setCloseButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,setCloseButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,setCloseButtonName,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,setCloseButtonName,OBJPROP_BGCOLOR,clrBlue);
   ObjectSetInteger(0,setCloseButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,retestButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,retestButtonName,OBJPROP_TEXT,"RETEST");
      ObjectSetInteger(0,retestButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,retestButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,retestButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,retestButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,retestButtonName,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,retestButtonName,OBJPROP_BGCOLOR,clrBlue);
   ObjectSetInteger(0,retestButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   hideAllPosition = xStart;
   
   HideButton(false);
   
   // second row
   xStart = 50;
   yStart = 60 + ySize;
   
   ObjectCreate(0,stoplossSizeButton,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,stoplossSizeButton,OBJPROP_TEXT,"SL1");
   ObjectSetInteger(0,stoplossSizeButton,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,stoplossSizeButton,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,stoplossSizeButton,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,stoplossSizeButton,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,stoplossSizeButton,OBJPROP_STATE,true);
   xStart += xSize;
   
   ObjectCreate(0,stoplossRiskButton,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,stoplossRiskButton,OBJPROP_TEXT,"SL2");
   ObjectSetInteger(0,stoplossRiskButton,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,stoplossRiskButton,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,stoplossRiskButton,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,stoplossRiskButton,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,stoplossRiskButton,OBJPROP_STATE,false);
   xStart += xSize;
      
   ObjectCreate(0,openOrderBuyButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,openOrderBuyButtonName,OBJPROP_TEXT,"Buy now");
   ObjectSetInteger(0,openOrderBuyButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,openOrderBuyButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,openOrderBuyButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,openOrderBuyButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,openOrderBuyButtonName,OBJPROP_STATE,false);
   xStart += xSize;
      
   ObjectCreate(0,openOrderSellButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,openOrderSellButtonName,OBJPROP_TEXT,"Sell now");
   ObjectSetInteger(0,openOrderSellButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,openOrderSellButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,openOrderSellButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,openOrderSellButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,openOrderSellButtonName,OBJPROP_STATE,false);
   xStart += xSize;
      
   ObjectCreate(0,closeAllButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,closeAllButtonName,OBJPROP_TEXT,"Close all");
   ObjectSetInteger(0,closeAllButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,closeAllButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,closeAllButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,closeAllButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,closeAllButtonName,OBJPROP_STATE,false);
   xStart += xSize;
      
   stoplossSizeSubOptions();
   
   ShowAllOrders();
}

void HideButton(bool state)
{
   ObjectCreate(0,hideAllButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,hideAllButtonName,OBJPROP_TEXT,"X");
   ObjectSetInteger(0,hideAllButtonName,OBJPROP_XDISTANCE,hideAllPosition);
   ObjectSetInteger(0,hideAllButtonName,OBJPROP_YDISTANCE,20);
   ObjectSetInteger(0,hideAllButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,hideAllButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,hideAllButtonName,OBJPROP_STATE,state);
}

void HideButtons()
{
   ObjectsDeleteAll();
   HideButton(true);
}

  
void OpenDaySubOptions()
{
   int xStart = 50;
   int yStart = ySize+20;

   ObjectCreate(0,openDayLowButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,openDayLowButtonName,OBJPROP_TEXT,"Low");
   ObjectSetInteger(0,openDayLowButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,openDayLowButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,openDayLowButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,openDayLowButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,openDayLowButtonName,OBJPROP_STATE,true);
   xStart += xSize;
 
   ObjectCreate(0,openDayHighButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,openDayHighButtonName,OBJPROP_TEXT,"High");
   ObjectSetInteger(0,openDayHighButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,openDayHighButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,openDayHighButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,openDayHighButtonName,OBJPROP_YDISTANCE,yStart);
}
  
  void OpenDaySubOptionsHide()
{
   ObjectDelete(openDayLowButtonName);
   ObjectDelete(openDayHighButtonName);
}
  
void ZonerSubOptions()
{
   int xStart = 50;
   int yStart = ySize+20;
   
   ObjectCreate(0,zonerLowButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,zonerLowButtonName,OBJPROP_TEXT,"Low");
   ObjectSetInteger(0,zonerLowButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,zonerLowButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,zonerLowButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,zonerLowButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,zonerLowButtonName,OBJPROP_STATE,true);
   xStart += xSize;
   
   ObjectCreate(0,zonerPivotButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,zonerPivotButtonName,OBJPROP_TEXT,"Pivot");
   ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_YDISTANCE,yStart);
   xStart += xSize;
   
   ObjectCreate(0,zonerHighButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,zonerHighButtonName,OBJPROP_TEXT,"High");
   ObjectSetInteger(0,zonerHighButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,zonerHighButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,zonerHighButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,zonerHighButtonName,OBJPROP_YDISTANCE,yStart);
}

void ZonerSubOptionsHide()
{
   ObjectDelete(zonerLowButtonName);
   ObjectDelete(zonerPivotButtonName);
   ObjectDelete(zonerHighButtonName);
}

void CloudSubOptions()
{
   int xStart = 50;
   int yStart = ySize+20;

   ObjectCreate(0,cloudRedButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudRedButtonName,OBJPROP_TEXT,"Red");
   ObjectSetInteger(0,cloudRedButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudRedButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudRedButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudRedButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,true);
   ObjectSetInteger(0,cloudRedButtonName,OBJPROP_COLOR,clrRed);
   xStart += xSize;
   
   ObjectCreate(0,cloudOrangeButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudOrangeButtonName,OBJPROP_TEXT,"Orange");
   ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_COLOR,clrOrange);
   xStart += xSize;
   
   ObjectCreate(0,cloudBlueButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudBlueButtonName,OBJPROP_TEXT,"Blue");
   ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_COLOR,clrBlue);
   xStart += xSize;
      
   ObjectCreate(0,cloudGreenButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudGreenButtonName,OBJPROP_TEXT,"Green");
   ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_COLOR,clrGreen);
   xStart += xSize;
   
   ObjectCreate(0,cloudVioletButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudVioletButtonName,OBJPROP_TEXT,"Violet");
   ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_COLOR,clrViolet);
   xStart += xSize;
   
   ObjectCreate(0,cloudYellowButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudYellowButtonName,OBJPROP_TEXT,"Yellow");
   ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_COLOR,clrYellow);
   xStart += xSize;
   
   ObjectCreate(0,cloudHighButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudHighButtonName,OBJPROP_TEXT,"High");
   ObjectSetInteger(0,cloudHighButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudHighButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudHighButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudHighButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,cloudHighButtonName,OBJPROP_STATE,true);
   xStart += xSize;
   
   ObjectCreate(0,cloudLowButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,cloudLowButtonName,OBJPROP_TEXT,"Low");
   ObjectSetInteger(0,cloudLowButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,cloudLowButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,cloudLowButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,cloudLowButtonName,OBJPROP_YDISTANCE,yStart);
   xStart += xSize;
}

void CloudSubOptionsHide()
{
   ObjectDelete(cloudRedButtonName);
   ObjectDelete(cloudOrangeButtonName);
   ObjectDelete(cloudBlueButtonName);
   ObjectDelete(cloudGreenButtonName);
   ObjectDelete(cloudVioletButtonName);
   ObjectDelete(cloudYellowButtonName);
   ObjectDelete(cloudHighButtonName);
   ObjectDelete(cloudLowButtonName);
}

void LevelSubOptions()
{
   int xStart = 50;
   int yStart = ySize+20;

   ObjectCreate(0,levelLabelName,OBJ_LABEL,0,0,0);
   ObjectSetText(levelLabelName,"Level: ",12);
   ObjectSetInteger(0,levelLabelName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,levelLabelName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,levelLabelName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,levelLabelName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,levelLabelName,OBJPROP_COLOR,clrWhite);
   xStart+=xSize;
   
   ObjectCreate(0,levelInputName,OBJ_EDIT,0,0,0);
   ObjectSetText(levelInputName,Bid,0);
   ObjectSetInteger(0,levelInputName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,levelInputName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,levelInputName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,levelInputName,OBJPROP_YDISTANCE,yStart);
}

void LevelSubOptionsHide()
{
   ObjectDelete(levelLabelName);
   ObjectDelete(levelInputName);
}

void EnvelopesSubOptions()
{
   int xStart = 50;
   int yStart = ySize+20;

   ObjectCreate(0,m5LowDownButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,m5LowDownButtonName,OBJPROP_TEXT,"m5 L D");
   ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,true);
   xStart += xSize;
   
   ObjectCreate(0,m5LowUpButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,m5LowUpButtonName,OBJPROP_TEXT,"m5 L U");
   ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,m5HighDownButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,m5HighDownButtonName,OBJPROP_TEXT,"m5 H D");
   ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,m5HighUpButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,m5HighUpButtonName,OBJPROP_TEXT,"m5 H U");
   ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,h1LowDownButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,h1LowDownButtonName,OBJPROP_TEXT,"h1 L D");
   ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,h1LowUpButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,h1LowUpButtonName,OBJPROP_TEXT,"h1 L U");
   ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,h1HighDownButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,h1HighDownButtonName,OBJPROP_TEXT,"h1 H D");
   ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
   xStart += xSize;
   
   ObjectCreate(0,h1HighUpButtonName,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,h1HighUpButtonName,OBJPROP_TEXT,"h1 H U");
   ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
   xStart += xSize;

}

void EnvelopesSubOptionsHide()
{
   ObjectDelete(m5LowDownButtonName);
   ObjectDelete(m5LowUpButtonName);
   ObjectDelete(m5HighDownButtonName);
   ObjectDelete(m5HighUpButtonName);
   ObjectDelete(h1LowDownButtonName);
   ObjectDelete(h1LowUpButtonName);
   ObjectDelete(h1HighDownButtonName);
   ObjectDelete(h1HighUpButtonName);
}


void stoplossSizeSubOptions()
{
   int xStart = 50;
   int yStart = 3*ySize+40;

   ObjectCreate(0,sizeLabel,OBJ_LABEL,0,0,0);
   ObjectSetString(0,sizeLabel,OBJPROP_TEXT,"Size:");
   ObjectSetInteger(0,sizeLabel,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,sizeLabel,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,sizeLabel,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,sizeLabel,OBJPROP_YDISTANCE,yStart);
   xStart += xSize;
   
   ObjectCreate(0,sizeEdit,OBJ_EDIT,0,0,0);
   ObjectSetString(0,sizeEdit,OBJPROP_TEXT,"0.1");
   ObjectSetInteger(0,sizeEdit,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,sizeEdit,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,sizeEdit,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,sizeEdit,OBJPROP_YDISTANCE,yStart);
   
   //second row
   yStart += ySize;
   xStart = 50;
   ObjectCreate(0,pointsLabel,OBJ_LABEL,0,0,0);
   ObjectSetString(0,pointsLabel,OBJPROP_TEXT,"Points:");
   ObjectSetInteger(0,pointsLabel,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,pointsLabel,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,pointsLabel,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,pointsLabel,OBJPROP_YDISTANCE,yStart);
   xStart += xSize;
   
   ObjectCreate(0,pointsEdit,OBJ_EDIT,0,0,0);
   ObjectSetString(0,pointsEdit,OBJPROP_TEXT,"1000");
   ObjectSetInteger(0,pointsEdit,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,pointsEdit,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,pointsEdit,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,pointsEdit,OBJPROP_YDISTANCE,yStart);
}

void stoplossSizeSubOptionsHide()
{
   ObjectDelete(sizeLabel);
   ObjectDelete(sizeEdit);
   ObjectDelete(pointsLabel);
   ObjectDelete(pointsEdit);
}

void stoplossRiskSubOptions()
{
   int xStart = 50;
   int yStart = 3*ySize+40;

   ObjectCreate(0,riskLabel,OBJ_LABEL,0,0,0);
   ObjectSetString(0,riskLabel,OBJPROP_TEXT,"Risk%:");
   ObjectSetInteger(0,riskLabel,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,riskLabel,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,riskLabel,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,riskLabel,OBJPROP_YSIZE,ySize);
   xStart += xSize;
   
   ObjectCreate(0,riskEdit,OBJ_EDIT,0,0,0);
   ObjectSetString(0,riskEdit,OBJPROP_TEXT,"10");
   ObjectSetInteger(0,riskEdit,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,riskEdit,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,riskEdit,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,riskEdit,OBJPROP_YSIZE,ySize);
   xStart += xSize;
   
   //second row
   yStart += ySize;
   xStart = 50;
   ObjectCreate(0,pointsLabel1,OBJ_LABEL,0,0,0);
   ObjectSetString(0,pointsLabel1,OBJPROP_TEXT,"Points:");
   ObjectSetInteger(0,pointsLabel1,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,pointsLabel1,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,pointsLabel1,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,pointsLabel1,OBJPROP_YSIZE,ySize);
   xStart += xSize;
   
   ObjectCreate(0,pointsEdit1,OBJ_EDIT,0,0,0);
   ObjectSetString(0,pointsEdit1,OBJPROP_TEXT,"1000");
   ObjectSetInteger(0,pointsEdit1,OBJPROP_XDISTANCE,xStart);
   ObjectSetInteger(0,pointsEdit1,OBJPROP_YDISTANCE,yStart);
   ObjectSetInteger(0,pointsEdit1,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,pointsEdit1,OBJPROP_YSIZE,ySize);
   xStart += xSize;
}

void stoplossRiskSubOptionsHide()
{
   ObjectDelete(riskLabel);
   ObjectDelete(riskEdit);
   ObjectDelete(pointsLabel1);
   ObjectDelete(pointsEdit1);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,0,0);
  }
  
  void CalculateOpenDayLevels()
  {
      //iCustom(NULL,0,"OpenCandle_MMD",0,0);
      datetime date=TimeCurrent();
      MqlDateTime dateStruct;
      TimeToStruct(date,dateStruct);
      dateStruct.hour = 0;
      dateStruct.min = 0;
      date = StructToTime(dateStruct);
      int shift=iBarShift(NULL,PERIOD_M1,date);
      double open1 = iOpen(NULL,PERIOD_M1,shift);
      double close1 = iClose(NULL,PERIOD_M1,shift);
      openDayLow = open1 < close1 ? open1 : close1;
      openDayHigh = open1 > close1 ? open1 : close1;
   }
   
double AccountPercentStopPips(string symbol, double percent, double lots)
{
    double balance   = AccountBalance();
    double tickvalue = MarketInfo(symbol, MODE_TICKVALUE);
    double lotsize   = MarketInfo(symbol, MODE_LOTSIZE);
    double spread    = MarketInfo(symbol, MODE_SPREAD);

    double stopLossPips = percent * balance / (lots * lotsize * tickvalue) - spread;

    return (stopLossPips);
}

double GetSizeByRiskAndPoints(double risk,double points)
{
    double balance   = AccountBalance();
    double tickvalue = MarketInfo(NULL, MODE_TICKVALUE);
    double lotsize   = MarketInfo(NULL, MODE_LOTSIZE);
    double spread    = MarketInfo(NULL, MODE_SPREAD);

    //double stopLossPips = percent * balance / (lots * lotsize * tickvalue) - spread;
    return risk * balance * 10 / (points * tickvalue*1000);  
}

bool IsNewBar() 
{ 
datetime curbar = Time[0]; // Open time of current bar

if (lastbar!=curbar) 
   { 
    lastbar=curbar; 
    return (true); 
   } 

  return(false); 

}

void CalculateBasicClouds()
{
      red0 = iMA(NULL,0,12,0,MODE_EMA,PRICE_CLOSE,0);
      red1 = iMA(NULL,0,12,0,MODE_SMA,PRICE_CLOSE,0);
      redLow = red0<red1 ? red0 : red1;
      redTop = red0>red1 ? red0 : red1;
      
      orange0 = iMA(NULL,0,48,0,MODE_EMA,PRICE_CLOSE,0);
      orange1 = iMA(NULL,0,48,0,MODE_SMA,PRICE_CLOSE,0);
      orangeLow = orange0<orange1 ? orange0 : orange1;
      orangeTop = orange0>orange1 ? orange0 : orange1;
}

void CalculateClouds()
{     
      blue0 = iMA(NULL,0,288,0,MODE_EMA,PRICE_CLOSE,0);
      blue1 = iMA(NULL,0,288,0,MODE_SMA,PRICE_CLOSE,0);
      blueLow = blue0<blue1 ? blue0 : blue1;
      blueTop = blue0>blue1 ? blue0 : blue1;
      
      green0 = iMA(NULL,0,1440,0,MODE_EMA,PRICE_CLOSE,0);
      green1 = iMA(NULL,0,1440,0,MODE_SMA,PRICE_CLOSE,0);
      greenLow = green0<green1 ? green0 : green1;
      greenTop = green0>green1 ? green0 : green1;
      
      violet0 = iMA(NULL,0,3456,0,MODE_EMA,PRICE_CLOSE,0);
      violet1 = iMA(NULL,0,3456,0,MODE_SMA,PRICE_CLOSE,0);
      violetLow = violet0<violet1 ? violet0 : violet1;
      violetTop = violet0>violet1 ? violet0 : violet1;
      
      yellow0 = iMA(NULL,0,7200,0,MODE_EMA,PRICE_CLOSE,0);
      yellow1 = iMA(NULL,0,7200,0,MODE_SMA,PRICE_CLOSE,0);
      yellowLow = yellow0<yellow1 ? yellow0 : yellow1;
      yellowTop = yellow0>yellow1 ? yellow0 : yellow1;
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      CalculateBasicClouds();

      if(IsNewBar())
      {
         CalculateClouds();
         CalculateOpenDayLevels();
      }
      
   
   //price
   double price = up ? Bid : Ask;
   
   int direction = up ? OP_BUY : OP_SELL;
   
   if(trade && !opened)
   {
      if(openOn == "OpenDay")
      {
         double level = openDayOption == "Low" ? openDayLow : openDayHigh;
         level += slip*Point;
         
         if((priceWhenOpen>level && Close[0]<=level) || (priceWhenOpen<level && Close[0]>=level))
         {
             openedOption = "openday";
             openedLevel = level - slip*Point;
         
             openPosition = true;
         }
      }
      else if(openOn=="Zoner")
      {
         double level = zonerOption == "Low" ? zonerLow : zonerOption == "High" ? zonerHigh : zonerPivot;
         level += slip*Point;
         
         if((priceWhenOpen>level && Close[0]<=level) || (priceWhenOpen<level && Close[0]>=level))
         {
            openedOption = "zoner";
            openedLevel = level - slip*Point;
            
            openPosition = true;
         }
      }
      else if(openOn == "Cloud")
      {
         double cloudLevel = 0;
         
         if(cloud=="Red")
         {
            cloudLevel = cloudOption == "Low" ? redLow : redTop;
         }
         else if(cloud=="Orange")
         {
            cloudLevel = cloudOption == "Low" ? orangeLow : orangeTop;
         }
         else if(cloud=="Blue")
         {
            cloudLevel = cloudOption == "Low" ? blueLow : blueTop;
         }
         else if(cloud=="Green")
         {
            cloudLevel = cloudOption == "Low" ? greenLow : greenTop;
         }
         else if(cloud=="Violet")
         {
            cloudLevel = cloudOption == "Low" ? violetLow : violetTop;
         }
         else if(cloud=="Yellow")
         {
            cloudLevel = cloudOption == "Low" ? yellowLow : yellowTop;
         }
         cloudLevel += slip*Point;
         
         if((priceWhenOpen>cloudLevel && Close[0]<=cloudLevel) || (priceWhenOpen<cloudLevel && Close[0]>=cloudLevel))
         {
            openedOption = "cloud";
            openedCloud = cloud;
            
            openPosition = true;
         }
      } 
      else if(openOn == "Level")
      {
         userLevel += slip*Point;
         
         if((priceWhenOpen>userLevel && Close[0]<=userLevel) || (priceWhenOpen<userLevel && Close[0]>=userLevel))
         {
            openedOption = "level";
            openedLevel = userLevel - slip*Point;
            
            openPosition = true;
         }
      }
      else if(openOn=="Envelopes")
      {
         double envelopesLevel = 0;
         
         if(envelopesOption=="m5Low")
         {
            envelopesLevel = iEnvelopes(NULL,PERIOD_M5,288,MODE_SMA,0,PRICE_CLOSE,0.48,MODE_LOWER,0);
         }
         else if(envelopesOption=="m5High")
         {
            envelopesLevel = iEnvelopes(NULL,PERIOD_M5,288,MODE_SMA,0,PRICE_CLOSE,0.48,MODE_UPPER,0);
         }
         else if(envelopesOption=="h1Low")
         {
             envelopesLevel = iEnvelopes(NULL,PERIOD_H1,288,MODE_SMA,0,PRICE_CLOSE,2.4,MODE_LOWER,0);
         }
         else if(envelopesOption=="h1High")
         {
            envelopesLevel = iEnvelopes(NULL,PERIOD_H1,288,MODE_SMA,0,PRICE_CLOSE,2.4,MODE_UPPER,0);
         }
         
         if((priceWhenOpen>envelopesLevel && Close[0]<=envelopesLevel) || (priceWhenOpen<envelopesLevel && Close[0]>=envelopesLevel))
         {
            openedOption = "Envelopes";
            openedLevel = envelopesLevel - slip*Point;
            
            openPosition = true;
         }
      }
      
      if(openNow)
      {
         openPosition = true;
         
         string nowText = "[1] Open manually" + " size: " + size + ", time: " + TimeCurrent() + ", SL: " + maxLoss;
                    
         ObjectCreate(0,openOrderLabelName,OBJ_LABEL,0,0,0);
         ObjectSetText(openOrderLabelName,nowText,12);
         ObjectSetInteger(0,openOrderLabelName,OBJPROP_XDISTANCE,50);
         ObjectSetInteger(0,openOrderLabelName,OBJPROP_YDISTANCE,160);
         ObjectSetInteger(0,openOrderLabelName,OBJPROP_COLOR,clrYellow);
      }
      
      
      if(openPosition)
      {
            openPrice = price;
            openCandleTime = Time[0];
            ticket=OrderSend(Symbol(),direction,size,price,3,0,0,"My order",0,0,clrGreen);
            opened = ticket>0;
            close = false;
            
            ShowAllOrders();
      }
      
      }
      else
      {
      if(opened && close)
      {
      
      //CLOSE
      if(openOn == "OpenDay")
      {
         double level = openDayOption == "Low" ? openDayLow : openDayHigh;
         level += slip*Point;
         
         if((priceWhenClose>level && Close[0]<=level) || (priceWhenClose<level && Close[0]>=level))
         {
             closePosition = true;
         }
      }
      else if(openOn=="Zoner")
      {
         double level = zonerOption == "Low" ? zonerLow : zonerOption == "High" ? zonerHigh : zonerPivot;
         level += slip*Point;
         
         if((priceWhenClose>level && Close[0]<=level) || (priceWhenClose<level && Close[0]>=level))
         {
            closePosition = true;
         }
      }
      else if(openOn == "Cloud")
      {
         double cloudLevel = 0;
         
         if(cloud=="Red")
         {
            cloudLevel = cloudOption == "Low" ? redLow : redTop;
         }
         else if(cloud=="Orange")
         {
            cloudLevel = cloudOption == "Low" ? orangeLow : orangeTop;
         }
         else if(cloud=="Blue")
         {
            cloudLevel = cloudOption == "Low" ? blueLow : blueTop;
         }
         else if(cloud=="Green")
         {
            cloudLevel = cloudOption == "Low" ? greenLow : greenTop;
         }
         else if(cloud=="Violet")
         {
            cloudLevel = cloudOption == "Low" ? violetLow : violetTop;
         }
         else if(cloud=="Yellow")
         {
            cloudLevel = cloudOption == "Low" ? yellowLow : yellowTop;
         }
         cloudLevel += slip*Point;
         
         if((priceWhenClose>cloudLevel && Close[0]<=cloudLevel) || (priceWhenClose<cloudLevel && Close[0]>=cloudLevel))
         {
            closePosition = true;
         }
      } 
      else if(openOn == "Level")
      {
         userLevel += slip*Point;
         
         if((priceWhenClose>userLevel && Close[0]<=userLevel) || (priceWhenClose<userLevel && Close[0]>=userLevel))
         {
            closePosition = true;
         }
      }
      }
      else if(openOn=="Envelopes")
      {
         double envelopesLevel = 0;
         
         if(envelopesOption=="m5Low")
         {
            double m5LowSma = iEnvelopes(NULL,PERIOD_M5,288,MODE_SMA,0,PRICE_CLOSE,0.48,MODE_LOWER,0);
            double m5LowEma = iEnvelopes(NULL,PERIOD_M5,288,MODE_EMA,0,PRICE_CLOSE,0.48,MODE_LOWER,0);
            double downEnvelopesLevel = m5LowSma < m5LowEma ? m5LowSma : m5LowEma;
            double upEnvelopesLevel = m5LowSma > m5LowEma ? m5LowSma : m5LowEma;           
            
            envelopesLevel = envelopesUp ? upEnvelopesLevel : downEnvelopesLevel;
         }
         else if(envelopesOption=="m5High")
         {
            double m5HighSma = iEnvelopes(NULL,PERIOD_M5,288,MODE_SMA,0,PRICE_CLOSE,0.48,MODE_UPPER,0);
            double m5HighEma = iEnvelopes(NULL,PERIOD_M5,288,MODE_EMA,0,PRICE_CLOSE,0.48,MODE_UPPER,0);
            double downEnvelopesLevel = m5HighSma < m5HighEma ? m5HighSma : m5HighEma;
            double upEnvelopesLevel = m5HighSma > m5HighEma ? m5HighSma : m5HighEma;  
            
            envelopesLevel = envelopesUp ? upEnvelopesLevel : downEnvelopesLevel;
         }
         else if(envelopesOption=="h1Low")
         {      
             double h1LowSma = iEnvelopes(NULL,PERIOD_H1,288,MODE_SMA,0,PRICE_CLOSE,2.4,MODE_LOWER,0);
             double h1LowEma = iEnvelopes(NULL,PERIOD_H1,288,MODE_EMA,0,PRICE_CLOSE,2.4,MODE_LOWER,0);
             double downEnvelopesLevel = h1LowSma < h1LowEma ? h1LowSma : h1LowEma;
             double upEnvelopesLevel = h1LowSma > h1LowEma ? h1LowSma : h1LowEma;
             
             envelopesLevel = envelopesUp ? upEnvelopesLevel : downEnvelopesLevel;
         }
         else if(envelopesOption=="h1High")
         {
            double h1HighSma = iEnvelopes(NULL,PERIOD_H1,288,MODE_SMA,0,PRICE_CLOSE,2.4,MODE_UPPER,0);
            double h1HighEma = iEnvelopes(NULL,PERIOD_H1,288,MODE_EMA,0,PRICE_CLOSE,2.4,MODE_UPPER,0);
            double downEnvelopesLevel = h1HighSma < h1HighEma ? h1HighSma : h1HighEma;
            double upEnvelopesLevel = h1HighSma > h1HighEma ? h1HighSma : h1HighEma;
           
            envelopesLevel = envelopesUp ? upEnvelopesLevel : downEnvelopesLevel;
         }
         
         if((priceWhenClose>envelopesLevel && Close[0]<=envelopesLevel) || (priceWhenClose<envelopesLevel && Close[0]>=envelopesLevel))
         {
            closePosition = true;
         }
      }

      if(opened && retest)
      {
      if(maxLoss>0 && ((direction==OP_BUY && Bid < maxLoss) || (direction==OP_SELL && Ask>maxLoss)))
      {
         closePosition = true;
      }
      
      double returnLevel;
      
      if(retestOption=="Cloud")
      {
      
      if(direction == OP_BUY)
      {
         returnLevel = cloud == "Red" ? redLow : cloud=="Orange" ? orangeLow : cloud=="Blue" ? blueLow : cloud=="Green" ? greenLow 
         : cloud == "Violet" ? violetLow : yellowLow;
      }
      else
      {
         returnLevel = cloud == "Red" ? redTop : cloud=="Orange" ? orangeTop : cloud=="Blue" ? blueTop : cloud=="Green" ? greenTop 
         : cloud == "Violet" ? violetTop : yellowTop;
      }
            
      }
      else
      {
         returnLevel = retestLevel;
      }
      
      if(Time[0]!=openCandleTime)
      {
         if((direction==OP_BUY && Close[0] > returnLevel) // && Open[1]<returnLevel && Close[1]<returnLevel) 
         || (direction==OP_SELL && Close[0]<returnLevel)) // && Open[1]>returnLevel && Close[1]>returnLevel))
         {
            closePosition = true;
         }
      }
      
      if(closePosition)
      {
          OrderClose(ticket,size,price,3);
          opened = false;
          trade = false;
          initData();
      }
      }
      
      }
      
      //close selected order
      if(selectedTicket!=0)
      {
         bool closeSelected = false;
         double l = 0;
         
         if(openOn=="Level")
         {
            l = userLevel;
         }
         else if(openOn=="Zoner")
         {
            l = zonerOption == "Low" ? zonerLow : zonerOption == "High" ? zonerHigh : zonerPivot;
         }
         else if(openOn=="OpenDay")
         {
            l = openDayOption == "Low" ? openDayLow : openDayHigh;
         }
         else if(openOn=="Cloud")
         {
            if(cloud=="Red")
            {
               l = cloudOption == "Low" ? redLow : redTop;
            }
            else if(cloud=="Orange")
            {
               l = cloudOption == "Low" ? orangeLow : orangeTop;
            }
            else if(cloud=="Blue")
            {
               l = cloudOption == "Low" ? blueLow : blueTop;
            }
            else if(cloud=="Green")
            {
               l = cloudOption == "Low" ? greenLow : greenTop;
            }
            else if(cloud=="Violet")
            {
               l = cloudOption == "Low" ? violetLow : violetTop;
            }
            else if(cloud=="Yellow")
            {
               l = cloudOption == "Low" ? yellowLow : yellowTop;
            }
         }
         
         l+=slip*Point;
         closeSelected = (priceWhenCloseSelected>l && Close[0]<=l) || (priceWhenCloseSelected<l && Close[0]>=l);
         
         if(closeSelected)
         {
            OrderClose(selectedTicket,size,price,3);
            opened = false;
            trade = false;
            initData();
         }
      }
      
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam  // Event parameter of string type
                  )
  {
  
//--- the left mouse button has been pressed on the chart
   if(id==CHARTEVENT_CLICK)
     {
      if(openOn == "Zoner")
      {
         int win = 0;
         ChartXYToTimePrice(0,lparam,dparam,win,zonerTime,zonerPrice);
         int shift=iBarShift(NULL,PERIOD_CURRENT,zonerTime);
         
         if((zonerPrice>Open[shift] && zonerPrice<Close[shift]) || (zonerPrice>Close[shift] && zonerPrice<Open[shift]))
         {
         Print("ok");
            zonerLow = Open[shift]<Close[shift] ? Open[shift] : Close[shift];
            zonerHigh = Open[shift]>Close[shift] ? Open[shift] : Close[shift];
            zonerPivot = Close[shift] > Open[shift] ? Open[shift] + (Close[shift] - Open[shift])/2 
            : Close[shift] + (Open[shift] - Close[shift])/2;
         }
      }
     }
     
     
     
      if(id==CHARTEVENT_OBJECT_CLICK)
      {
         if(sparam==openDayButtonName)
         {
            openOn = "OpenDay";
            ObjectSetInteger(0,openDayButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,zonerButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,levelButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,envelopesButtonName,OBJPROP_STATE,false);
            
            OpenDaySubOptions();
            ZonerSubOptionsHide();
            CloudSubOptionsHide();
            LevelSubOptionsHide();
            EnvelopesSubOptionsHide();
         }
         else if(sparam==zonerButtonName)
         {
            openOn = "Zoner";
            ObjectSetInteger(0,zonerButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,openDayButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,levelButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,envelopesButtonName,OBJPROP_STATE,false);
            
            OpenDaySubOptionsHide();
            ZonerSubOptions();
            CloudSubOptionsHide();
            LevelSubOptionsHide();
            EnvelopesSubOptionsHide();
         }
         else if(sparam==cloudButtonName)
         {
            openOn = "Cloud";
            ObjectSetInteger(0,cloudButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,openDayButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,levelButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,envelopesButtonName,OBJPROP_STATE,false);
            
            OpenDaySubOptionsHide();
            ZonerSubOptionsHide();
            CloudSubOptions();
            LevelSubOptionsHide();
            EnvelopesSubOptionsHide();
         }
         else if(sparam==levelButtonName)
         {
            openOn = "Level";
            ObjectSetInteger(0,levelButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,openDayButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,envelopesButtonName,OBJPROP_STATE,false);
            
            OpenDaySubOptionsHide();
            ZonerSubOptionsHide();
            CloudSubOptionsHide();
            LevelSubOptions();
            EnvelopesSubOptionsHide();
         }
         else if(sparam==envelopesButtonName)
         {
            openOn = "Envelopes";
            ObjectSetInteger(0,levelButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,openDayButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,envelopesButtonName,OBJPROP_STATE,true);
            
            OpenDaySubOptionsHide();
            ZonerSubOptionsHide();
            CloudSubOptionsHide();
            LevelSubOptionsHide();
            EnvelopesSubOptions();
         }
         else if(sparam==openDayLowButtonName)
         {
            openDayOption = "Low";
            ObjectSetInteger(0,openDayLowButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,openDayHighButtonName,OBJPROP_STATE,false);     
         }
         else if(sparam==openDayHighButtonName)
         {
            openDayOption = "High";
            ObjectSetInteger(0,openDayLowButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,openDayHighButtonName,OBJPROP_STATE,true);     
         }
         else if(sparam==zonerHighButtonName)
         {
            zonerOption = "High";
            ObjectSetInteger(0,zonerHighButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerLowButtonName,OBJPROP_STATE,false);     
         }
         else if(sparam==zonerPivotButtonName)
         {
            zonerOption = "Pivot";
            ObjectSetInteger(0,zonerHighButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,zonerLowButtonName,OBJPROP_STATE,false);     
         }
         else if(sparam==zonerLowButtonName)
         {
            zonerOption = "Low";
            ObjectSetInteger(0,zonerHighButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerPivotButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,zonerLowButtonName,OBJPROP_STATE,true);     
         }
         else if(sparam==cloudRedButtonName)
         {
            cloud = "Red";
            ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_STATE,false);  
            ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_STATE,false);      
         }
         else if(sparam==cloudOrangeButtonName)
         {
            cloud = "Orange";
            ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_STATE,false);  
            ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_STATE,false);      
         }
         else if(sparam==cloudBlueButtonName)
         {
            cloud = "Blue";
            ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_STATE,false);  
            ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_STATE,false);      
         }
         else if(sparam==cloudGreenButtonName)
         {
            cloud = "Green";
            ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_STATE,false);  
            ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_STATE,false);      
         } 
         else if(sparam==cloudVioletButtonName)
         {
            cloud = "Violet";
            ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_STATE,true);  
            ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_STATE,false);      
         }         
         else if(sparam==cloudYellowButtonName)
         {
            cloud = "Yellow";
            ObjectSetInteger(0,cloudRedButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudOrangeButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudBlueButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudGreenButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudVioletButtonName,OBJPROP_STATE,false);  
            ObjectSetInteger(0,cloudYellowButtonName,OBJPROP_STATE,true);      
         }
         else if(sparam==cloudHighButtonName)
         {
            cloudOption = "High";
            ObjectSetInteger(0,cloudHighButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,cloudLowButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==cloudLowButtonName)
         {
            cloudOption = "Low";
            ObjectSetInteger(0,cloudHighButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,cloudLowButtonName,OBJPROP_STATE,true);
         }
         else if(sparam==m5LowDownButtonName)
         {
            envelopesOption = "m5Low";
            envelopesUp = false;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==m5LowUpButtonName)
         {
            envelopesOption = "m5Low";
            envelopesUp = true;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==m5HighDownButtonName)
         {
            envelopesOption = "m5High";
            envelopesUp = false;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==m5HighUpButtonName)
         {
            envelopesOption = "m5High";
            envelopesUp = true;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==h1LowDownButtonName)
         {
            envelopesOption = "h1Low";
            envelopesUp = false;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==h1LowUpButtonName)
         {
            envelopesOption = "h1Low";
            envelopesUp = true;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==h1HighDownButtonName)
         {
            envelopesOption = "h1High";
            envelopesUp = false;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==h1HighUpButtonName)
         {
            envelopesOption = "h1High";
            envelopesUp = true;
            ObjectSetInteger(0,m5LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,m5HighUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1LowUpButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighDownButtonName,OBJPROP_STATE,false);
            ObjectSetInteger(0,h1HighUpButtonName,OBJPROP_STATE,true);
         }
         else if(sparam==buyButtonName)
         { 
            up = true;
            ObjectSetInteger(0,buyButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,sellButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==sellButtonName)
         {
            up = false;
            ObjectSetInteger(0,sellButtonName,OBJPROP_STATE,true);
            ObjectSetInteger(0,buyButtonName,OBJPROP_STATE,false);
         }
         else if(sparam==stoplossSizeButton)
         {
            slOption = "sizeAndPips";
            
            ObjectSetInteger(0,stoplossSizeButton,OBJPROP_STATE,true);
            ObjectSetInteger(0,stoplossRiskButton,OBJPROP_STATE,false);
            stoplossSizeSubOptions();
            stoplossRiskSubOptionsHide();
         }
         else if(sparam==stoplossRiskButton)
         {
            slOption = "riskAndPips";
            
            ObjectSetInteger(0,stoplossSizeButton,OBJPROP_STATE,false);
            ObjectSetInteger(0,stoplossRiskButton,OBJPROP_STATE,true);
            stoplossSizeSubOptionsHide();
            stoplossRiskSubOptions();
         }
         else if(sparam==openOrderBuyButtonName)
         {
            trade = true;
            up = true;
            openNow = true;
         }
         else if(sparam==openOrderSellButtonName)
         {
            trade = true;
            up = false;
            openNow = true;
         }
         else if(sparam==hideAllButtonName)
         {
         
         bool state = ObjectGetInteger(0,hideAllButtonName,OBJPROP_STATE);
         
         if(state)
         {
            HideButtons();
         }
         else
         {
            ShowButtons();
         }
         }
         else if(sparam==closeAllButtonName)
         {
            CloseAll();
         }
         else if(sparam==setOpenButtonName)
         {      
         
            priceWhenOpen = Close[0];
            trade = true;
            string l;
            ObjectGetString(0,levelInputName,OBJPROP_TEXT,0,l);
            userLevel = l;
            
            string s;
            ObjectGetString(0,slipInputName,OBJPROP_TEXT,0,s);
            slip = s;
            ObjectSetText(slipInputName,0,12);
            
            if(slOption=="sizeAndPips")
            {
               string sizeString;
               ObjectGetString(0,sizeEdit,OBJPROP_TEXT,0,sizeString);
               size = sizeString;
               
               string pointsString;
               ObjectGetString(0,pointsEdit,OBJPROP_TEXT,0,pointsString);
               points = pointsString;           
            }
            else if(slOption=="riskAndPips")
            {
               string riskString;
               ObjectGetString(0,riskEdit,OBJPROP_TEXT,0,riskString);
               risk = riskString;
               
               string pointsString;
               ObjectGetString(0,pointsEdit1,OBJPROP_TEXT,0,pointsString);
               points = pointsString;  
               
               size = GetSizeByRiskAndPoints(risk,points);
            }
            
            maxLoss = up ? Close[0] - points*Point : Close[0] + points*Point;
                       
            string openedOrderText;
            
            if(openOn=="OpenDay")
            {
               CalculateOpenDayLevels();
            
               openedOrderText = "[1] Open on open day: " + (up ? "BUY " : "SELL") + "On " + openDayOption +": "
                + (openDayOption=="Low" ? openDayLow : openDayHigh);
            }
            else if(openOn=="Zoner")
            {
               openedOrderText = "[1] Open on zoner: " + (up ? "BUY " : "SELL") + "On " + zonerOption +": "
                + (zonerOption=="Low" ? zonerLow : zonerOption=="High" ? zonerHigh : zonerPivot);
            }
            else if(openOn=="Cloud")
            {
                openedOrderText = "[1] Open on cloud: " + (up ? "BUY " : "SELL") + "On " + cloud + ": " + cloudOption;
            }
            else if(openOn=="Level")
            { 
               openedOrderText = "[1] Open on level: " + (up ? "BUY " : "SELL") + "On level: " + userLevel;
            }
            else if(openOn=="Envelopes")
            {
               openedOrderText = "[1] Open on level: " + (up ? "BUY " : "SELL") + "On: " + envelopesOption;
            }
            
            openedOrderText += ", size: " + size + ", time: " + TimeCurrent() + ", SL: " + maxLoss;
            
               ObjectCreate(0,openOrderLabelName,OBJ_LABEL,0,0,0);
               ObjectSetText(openOrderLabelName,openedOrderText,12);
               ObjectSetInteger(0,openOrderLabelName,OBJPROP_XDISTANCE,50);
               ObjectSetInteger(0,openOrderLabelName,OBJPROP_YDISTANCE,160);
               ObjectSetInteger(0,openOrderLabelName,OBJPROP_COLOR,clrYellow);
               
               
         }
         else if(sparam==setCloseButtonName)
         {
            priceWhenClose = Close[0];
            close = true;
            string l;
            ObjectGetString(0,levelInputName,OBJPROP_TEXT,0,l);
            userLevel = l;
            
            string s;
            ObjectGetString(0,slipInputName,OBJPROP_TEXT,0,s);
            slip = s;
            ObjectSetText(slipInputName,0,12);
         
             
            string closeOrderText;
            
            if(openOn=="OpenDay")
            {
               CalculateOpenDayLevels();
            
               closeOrderText = "[1] Close on open day: " + openDayOption +": "
                + (openDayOption=="Low" ? openDayLow : openDayHigh);
            }
            else if(openOn=="Zoner")
            {
               closeOrderText = "[1] Close on zoner: " + zonerOption +": "
                + (zonerOption=="Low" ? zonerLow : zonerOption=="High" ? zonerHigh : zonerPivot);
            }
            else if(openOn=="Cloud")
            {
                closeOrderText = "[1] Close on cloud: " + cloud + ": " + cloudOption;
            }
            else if(openOn=="Level")
            { 
               closeOrderText = "[1] Close on level:" + userLevel;
            }
            
               ObjectCreate(0,closeOrderLabelName,OBJ_LABEL,0,0,0);
               ObjectSetText(closeOrderLabelName,closeOrderText,12);
               ObjectSetInteger(0,closeOrderLabelName,OBJPROP_XDISTANCE,50);
               ObjectSetInteger(0,closeOrderLabelName,OBJPROP_YDISTANCE,180);
               ObjectSetInteger(0,closeOrderLabelName,OBJPROP_COLOR,clrYellow);
               
         }
         else if(sparam==retestButtonName)
         {
            retest = true;
            string retestText;
         
            if(openOn=="OpenDay")
            {
               CalculateOpenDayLevels();
            
               retestOption = "OpenDay";
               retestLevel = openDayOption=="Low" ? openDayLow : openDayHigh;
               
               retestText = "[1] Retest on open day: " + openDayOption +": " + retestLevel;
            }
            else if(openOn=="Zoner")
            {
               retestOption = "Zoner";
               retestLevel = zonerOption=="Low" ? zonerLow : zonerOption=="High" ? zonerHigh : zonerPivot;
               
               retestText = "[1] Retest on zoner: " + zonerOption +": " + retestLevel;
            }
            else if(openOn=="Cloud")
            {
                retestOption = "Cloud";
                retestCloud = cloud;
                retestCloudOption = cloudOption;
                
                retestText = "[1] Retest on cloud: " + cloud +": " + cloudOption;
            }
            else if(openOn=="Level")
            { 
               retestOption = "Level";
               retestLevel = userLevel;
               
               retestText = "[1] Retest on level: " + userLevel;
            }
               ObjectCreate(0,retestLabelName,OBJ_LABEL,0,0,0);
               ObjectSetText(retestLabelName,retestText,12);
               ObjectSetInteger(0,retestLabelName,OBJPROP_XDISTANCE,50);
               ObjectSetInteger(0,retestLabelName,OBJPROP_YDISTANCE,200);
               ObjectSetInteger(0,retestLabelName,OBJPROP_COLOR,clrYellow);
         }
         else if(StringFind(sparam,"btnOrder_",0)!=-1)
         {
            priceWhenCloseSelected = Close[0];
            string s = StringSubstr(sparam,9,0);
            selectedTicket = (int)s;
            
            string l;
            ObjectGetString(0,levelInputName,OBJPROP_TEXT,0,l);
            userLevel = l;
            
         }
      }
  }
  
  
  class TradeOptions
  {   
  public:
      bool on;
      
      bool opened;
      int ticket;
      double priceWhenOpen;
      double priceWhenClose;
      bool openPosition;
      bool closePosition;
      double maxLoss;
      double slip;
      double openPrice;
      double pipsStopLoss;
      double risk;
      datetime lastbar;
      double points;

      string openOn;
      bool trade;
      bool close;
      bool up;
      double size;

      string openDayOption;
      double openDayLow;
      double openDayHigh;

      string zonerOption;
      datetime zonerTime; 
      double zonerPrice;
      double zonerLow;
      double zonerHigh;
      double zonerPivot;

      double userLevel;

      string cloud;
      string cloudOption;

      int openedDirection;
      double openedPrice;
      string openedOption;
      string openedLevel;
      string openedCloud;
      datetime openCandleTime;


      string slOption;
      
      
      //TradeOptions() { on = false; };
      
      TradeOptions()
       { 
         on = false;
         opened = false;
         ticket = ticket;
         priceWhenOpen = priceWhenOpen;
         priceWhenClose = priceWhenClose;
         openPosition = openPosition;
         closePosition = closePosition;
         maxLoss = maxLoss;
         slip = slip;
         openPrice = openPrice;
         pipsStopLoss = pipsStopLoss;
         risk = risk;
         lastbar = lastbar;
         points = points;
         openOn = openOn;
         trade = trade;
         close= close;
         up = up;
         size = size;
         openDayOption = openDayOption;
         openDayLow = openDayLow;
         openDayHigh = openDayHigh;
         zonerOption = zonerOption;
         zonerTime = zonerTime; 
         zonerPrice = zonerPrice;
         zonerLow = zonerLow;
         zonerHigh = zonerHigh;
         zonerPivot = zonerPivot;
         userLevel = userLevel;
         cloud = cloud;
         cloudOption = cloudOption;
         openedDirection = openedDirection;
         openedPrice = openedPrice;
         openedOption = openedOption;
         openedLevel = openedLevel;
         openedCloud = openedCloud;
         openCandleTime = openCandleTime;
         slOption = slOption;
       }
  };
  
void ShowAllOrders()
{ 
   int numOfOrders = OrdersTotal();
   int yd = 200;
         
   for(int index = numOfOrders - 1; index >= 0; index--)
   {
     OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol() == Symbol())
     {
         int t = OrderTicket();
         string lblName = "lblOrder_" + t;
         string btnName = "btnOrder_" + t;
                
         ObjectCreate(0,lblName,OBJ_LABEL,0,0,0);
         ObjectSetString(0,lblName,OBJPROP_TEXT,t);
         ObjectSetInteger(0,lblName,OBJPROP_XDISTANCE,50);
         ObjectSetInteger(0,lblName,OBJPROP_YDISTANCE,yd);
         ObjectSetInteger(0,lblName,OBJPROP_STATE,false);
         ObjectSetInteger(0,lblName,OBJPROP_COLOR,clrBlueViolet);

         ObjectCreate(0,btnName,OBJ_BUTTON,0,0,0);
         ObjectSetString(0,btnName,OBJPROP_TEXT,"CLOSE");
         ObjectSetInteger(0,btnName,OBJPROP_XDISTANCE,100);
         ObjectSetInteger(0,btnName,OBJPROP_YDISTANCE,yd);
         ObjectSetInteger(0,btnName,OBJPROP_STATE,false);

         yd+=20;
     }
   }
}

void hideAllOrders()
{
  string s1  = "lblOrder"; // This is the object name you want to remove
  string s2  = "btnOrder";
  int TotalObject;
  TotalObject = ObjectsTotal(0,0,-1);

  for(int i=0;i<TotalObject;i++) 
  {
     if (StringFind(ObjectName(0,i,0,-1),s1,0)>0 || StringFind(ObjectName(0,i,0,-1),s2,0)>0)
     {
         ObjectDelete(0,ObjectName(0,i,0,-1));
     }
   }
}

int CloseAll()
{ 
   bool rv = NO_ERROR;
   int numOfOrders = OrdersTotal();
   int FirstOrderType = 0;
   
   for (int index = 0; index < OrdersTotal(); index++)   
     {
       OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
       if (OrderSymbol() == Symbol()) 
       {
         FirstOrderType = OrderType();
         break;
       }
     }   
         
   for(int index = numOfOrders - 1; index >= 0; index--)
   {
      OrderSelect(index, SELECT_BY_POS, MODE_TRADES);
      
      if (OrderSymbol() == Symbol())
      switch (OrderType())
      {
         case OP_BUY: 
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), SLIPPAGE, Red))
               rv = AT_LEAST_ONE_FAILED;
            break;

         case OP_SELL:
            if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), SLIPPAGE, Red))
               rv = AT_LEAST_ONE_FAILED;
            break;

         case OP_BUYLIMIT: 
         case OP_SELLLIMIT:
         case OP_BUYSTOP: 
         case OP_SELLSTOP:
            if (!OrderDelete(OrderTicket()))
               rv = AT_LEAST_ONE_FAILED;
            break;
      }
   }

   return(rv);
}