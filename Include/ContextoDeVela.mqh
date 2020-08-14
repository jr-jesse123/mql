//+------------------------------------------------------------------+
//|                                               ContextoDeVela.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

  class ContextoDeVela
    {
    
    
    
  public:
                       ContextoDeVela(void);
   string ObterJsonString();
                          
   private:
double obv_Buffer[];
double mm_Buffer_400[];
double mm_Buffer_200[];
double mm_Buffer_80[];
double mm_Buffer_21[];
double mm_Buffer_9E[]; 
MqlRates MR[];                     
CJAVal JS;
    };
 
ContextoDeVela::ContextoDeVela(void)
{
        CopyBuffer(mm_Handle_9E,0/*nr do buffer*/,0,1,mm_Buffer_9E);
        JS["MM9E"] = mm_Buffer_9E[0];
        CopyBuffer(mm_Handle_21,0/*nr do buffer*/,0,1,mm_Buffer_21);
        JS["MM21"] = mm_Buffer_21[0];
        CopyBuffer(mm_Handle_80,0/*nr do buffer*/,0,1,mm_Buffer_80);
         JS["MM80"] = mm_Buffer_80[0];
        CopyBuffer(mm_Handle_200,0/*nr do buffer*/,0,1,mm_Buffer_200);
        JS["MM200"] = mm_Buffer_200[0];
        CopyBuffer(mm_Handle_400,0/*nr do buffer*/,0,1,mm_Buffer_400);
        JS["MM400"] = mm_Buffer_400[0];
        CopyBuffer(obv_Handle,0/*nr do buffer*/,0,1,obv_Buffer);
        JS["OBV"] = obv_Buffer[0];
         CopyRates(_Symbol,_Period,0,1,MR);
         JS["VELA"]["close"] = MR[0].close;
         JS["VELA"]["high"] = MR[0].high;
         JS["VELA"]["low"] = MR[0].low;
         JS["VELA"]["open"] = MR[0].open;
         JS["VELA"]["real_volume"] = MR[0].real_volume;
         JS["VELA"]["spread"] = MR[0].spread;
         JS["VELA"]["tick_volume"] = MR[0].tick_volume;
         JS["VELA"]["time"] = TimeToString(MR[0].time);
}
string ContextoDeVela::ObterJsonString(void)
{
   string output;
   bool sucess ;
    JS.Serialize(output);
   
   return output;
}

