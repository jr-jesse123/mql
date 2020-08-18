//+------------------------------------------------------------------+
//|                                               ContextoDeVela.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <JAson.mqh>
#include <Indicadores.mqh>
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



  class CSerializadorDeVela
    {
    
   public:
                       CSerializadorDeVela(void);
   string              ObterVelaSerializada();
   string ObterJsonString();
                          
   private:
  
   MqlRates MR[];                     
   CJAVal JS;
    };
 
 
string CSerializadorDeVela::ObterVelaSerializada(void)
{
   string output;
   JS.Serialize(output);
   return output;
} 
 
CSerializadorDeVela::CSerializadorDeVela(void)
{

         Indicadores Ind;        
         CopyRates(_Symbol,_Period,0,1,MR);
         JS["Close"] = MR[0].close;
         JS["High"] = MR[0].high;
         JS["Low"] = MR[0].low;
         JS["Open"] = MR[0].open;
         JS["Real_volume"] = MR[0].real_volume;
         JS["Spread"] = MR[0].spread;
         JS["Tick_volume"] = MR[0].tick_volume;
         JS["Time"] = TimeToString(MR[0].time);
         
         JS["contextoDeVela"].Set(Ind.ObterContexto());
         
         
         
}
string CSerializadorDeVela::ObterJsonString(void)
{
   string output;
   bool sucess ;
    JS.Serialize(output);
   
   return output;
}

