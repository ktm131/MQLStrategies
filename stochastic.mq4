//+------------------------------------------------------------------+
//|                                                   stochastic.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
bool openedL, openedS;
int ticketL, ticketS;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!openedL && StochasticSignal(true) && movingAverages2Signal(5,40))
   {
       ticketL=OrderSend(Symbol(),OP_BUY,0.1,Ask,3,0,0,"My order",0,0,clrGreen);
       openedL = ticketL>0;
   }
   
   if(openedL && (StochasticSignal(false) || !movingAverages2Signal(5,40)))
   {
       bool closed = OrderClose(ticketL,0.1,Bid,2,clrRed);
       openedL = closed;
   }
  }
//+------------------------------------------------------------------+
//| Timer function                                                    |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
  
  bool StochasticSignal(bool up)
  {
     double d = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);
     double k = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);
     
     if(up)
     {
         return d>k && d<20 && k <20;
     }
     else
     {
         return d<k && d>80 && k>80;
     }
  }
  
    bool movingAverages2Signal(int period1,int period2)
  {
      double ima1 = iMA(NULL,0,period1,0,MODE_SMMA,PRICE_MEDIAN,0);
      double ima2 = iMA(NULL,0,period2,0,MODE_SMMA,PRICE_MEDIAN,0);
      
      return ima1 > ima2;
  }
//+------------------------------------------------------------------+
