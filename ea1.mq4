//+------------------------------------------------------------------+
//|                                                   movingstop.mq4 |
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

bool opened;
int ticket;
datetime lastbar;
bool addedPosition = false;
extern int distance = 300;
extern double size = 0.1;
extern double pass = 100;
int i= 0;
int addedIndex = -1;
int resetIndex = -1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     MathSrand(GetTickCount());
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---    
     double level = iCustom(NULL,PERIOD_CURRENT,"StepMA-of-rsi-adaptive-ema-2_1",0,1);
     double trend = iCustom(NULL,PERIOD_CURRENT,"StepMA-of-rsi-adaptive-ema-2_1",6,1);
     double trendShift2 = iCustom(NULL,PERIOD_CURRENT,"StepMA-of-rsi-adaptive-ema-2_1",6,2);
     int direction = trend == 1 ? OP_BUY : OP_SELL;
     double price = trend == 1 ? Ask : Bid;
         
     if(IsNewBar())
     {
         
         //testing drawing
         /*
         ObjectCreate(0,"p"+i,OBJ_TEXT,0,Time[0],level);
         ObjectSetString(0,"p"+i,OBJPROP_TEXT,"*");
         ObjectSetInteger(0,"p"+i,OBJPROP_COLOR,trend==1?clrGreen:clrRed);
         */
         
         i++;
     
         if(trend!=trendShift2)
         {
            //close on trend change
            bool closed = CloseAll() != AT_LEAST_ONE_FAILED;
            
            if(closed)
            {
                 ticket=OrderSend(Symbol(),direction,size,price,3,0,0,"My order",0,0,clrGreen);
                 opened = ticket>0;
            }                   
         }
         
         ModifyStops(level);
     }
    
    //add positions to trend
    if(!addedPosition && i!=resetIndex)
    {    
         if(addedIndex!=i-1 && addedIndex!=i && ((trend==-1 && Close[1]<=level-pass*Point && Close[0]<level) || (trend==1 && Close[1]>=level+pass*Point && Close[0]>level)))
         {
         
                 bool trendChanged = false;
                 bool passedLine = false;
                 int shift = 1;
                 int previousTrend = trend;
                 bool secondPass = false;
                 
                 
                 while(!trendChanged && !passedLine)
                 {
                     shift++;
                     double shiftLevel = iCustom(NULL,PERIOD_CURRENT,"StepMA-of-rsi-adaptive-ema-2_1",0,shift);
                     double shiftTrend = iCustom(NULL,PERIOD_CURRENT,"StepMA-of-rsi-adaptive-ema-2_1",6,shift);
         
                     if(shiftTrend!=previousTrend)
                     {
                        trendChanged = true;
                     }
                     else
                     {
                        if(!secondPass)
                        {                  
                           secondPass = (trend==-1 && High[shift]>=shiftLevel+pass*Point) || (trend==1 && Low[shift]<=shiftLevel-pass*Point);
                        } 
                        else
                        {
                        
                           if(High[shift]>=shiftLevel>=Low[shift] || High[shift+1]<=shiftLevel<=Low[shift] 
                           || High[shift+1]>=shiftLevel>=Low[shift])
                           {
                              passedLine = true;
                           }
                        }
                     }
                 }
                 
                 if(passedLine)
                 {
                     ticket=OrderSend(Symbol(),direction,size,price,3,0,0,"My order",0,0,clrGreen);
                     addedPosition = true;
                     ModifyStops(level);
                     addedIndex = i;
                 }
      }
      }
      else
      {
        if((trend==-1 && Close[0]>=level+pass*Point) || (trend==1 && Close[0]<=level-pass*Point))
        {
            addedPosition = false;
            resetIndex = i;
        }
        /*
        if(High[0]>=level>=Low[0] || High[1]<=level<=Low[0] || High[1]>=level>=Low[0])
        {
          addedPosition = false;
        }
        */
     }
     
  }
//+------------------------------------------------------------------+
int GetLastOrderTicket()
{
   int lastOpenTime = 0, needleTicket = 0;
   
   for(int i = (OrdersTotal()-1); i >= 0; i --)
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      int curOpenTime = OrderOpenTime();
     
      
      if(curOpenTime > lastOpenTime && OrderSymbol()==Symbol())
      {
         lastOpenTime = curOpenTime;
         needleTicket = OrderTicket();
      }
   }
   
   return needleTicket;
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

void ModifyStops(double level)
{
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
      
      if(OrderSymbol() == Symbol())
      {
         int type = OrderType();
         int t = OrderTicket();
         double slLevel = type == OP_BUY ? level-distance*Point : level + distance * Point;
         OrderModify(t,OrderOpenPrice(),slLevel,OrderTakeProfit(),0); 
      }
      
      
   }
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