//+------------------------------------------------------------------+
//|                                                  Indicadores.mqh |
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
#include <JAson.mqh>

  class  Indicadores
  {
public:
//--- PROPRIEDADES ESTÁTICAS 

   static int mm_Handle_9E;
   static int mm_Handle_21;
   static int mm_Handle_80;
   static int mm_Handle_200;
   static int mm_Handle_400;
   static int MACD_Handle;
   static int obv_Handle;

//--- PROPRIEDADES DE INSTANCIA
   
   

//--- MÉTODOS

Indicadores();

   CJAVal ObterContexto();
   
   double mm_Buffer_9E(int bufferNum =0, int startPosition = 0, int count = 1); 
   void mm_Buffer_9E(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1); 
   
   double mm_Buffer_21(int bufferNum =0, int startPosition = 0, int count = 1);
   void mm_Buffer_21(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1);
   
   double mm_Buffer_80(int bufferNum =0, int startPosition = 0, int count = 1);
   void mm_Buffer_80(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1);
   
   double mm_Buffer_200(int bufferNum =0, int startPosition = 0, int count = 1);
   void mm_Buffer_200(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1);
   
   double mm_Buffer_400(int bufferNum =0, int startPosition = 0, int count = 1);
   void mm_Buffer_400(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1);
   
   double obv_Buffer(int bufferNum =0, int startPosition = 0, int count = 1);
   void obv_Buffer(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1);
   
   double MACD_Buffer(int bufferNum =0, int startPosition = 0, int count = 1);
   void MACD_Buffer(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1);
   

            ;
  };

int static Indicadores::mm_Handle_9E =0;
int static Indicadores::mm_Handle_21 =0;
int static Indicadores::mm_Handle_80 =0;
int static Indicadores::mm_Handle_200 =0;
int static Indicadores::mm_Handle_400 =0;
int static Indicadores::obv_Handle =0;
int static Indicadores::MACD_Handle = 0;



Indicadores::Indicadores(void)
{
  obv_Handle = iOBV(_Symbol, _Period,VOLUME_REAL);
  MACD_Handle = iMACD(_Symbol, _Period,12,26,9,PRICE_CLOSE);
  mm_Handle_9E = iMA(_Symbol, _Period,9,0,MODE_EMA,PRICE_CLOSE);
  mm_Handle_21 = iMA(_Symbol, _Period,21,0,MODE_SMA,PRICE_CLOSE);
  mm_Handle_80 = iMA(_Symbol, _Period,80,0,MODE_SMA,PRICE_CLOSE);
  mm_Handle_200 = iMA(_Symbol, _Period,200,0,MODE_SMA,PRICE_CLOSE);
  mm_Handle_400 = iMA(_Symbol, _Period,400,0,MODE_SMA,PRICE_CLOSE);
  
}


double Indicadores::mm_Buffer_9E(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_9E,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::mm_Buffer_9E(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_9E,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}

double Indicadores::mm_Buffer_21(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_21,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::mm_Buffer_21(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_21,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}



double Indicadores::mm_Buffer_80(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_80,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::mm_Buffer_80(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_80,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}


double Indicadores::mm_Buffer_200(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_200,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::mm_Buffer_200(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_200,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}



double Indicadores::mm_Buffer_400(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_400,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::mm_Buffer_400(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(mm_Handle_400,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}


double Indicadores::obv_Buffer(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(obv_Handle,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::obv_Buffer(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(obv_Handle,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}

double Indicadores::MACD_Buffer(int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(MACD_Handle,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
   return output[0];
}

void Indicadores::MACD_Buffer(double &buffer[], int bufferNum =0, int startPosition = 0, int count = 1)
{
   double output[];
   CopyBuffer(MACD_Handle,bufferNum,startPosition,count ,output);
   ArraySetAsSeries(output,true);
}

CJAVal Indicadores::ObterContexto(void)
{
   
   CJAVal JS;
   JS["MM9E"] = mm_Buffer_9E();
   JS["MM21"] = mm_Buffer_9E();
   JS["MM80"] = mm_Buffer_9E();
   JS["MM200"] = mm_Buffer_9E();
   JS["MM400"] = mm_Buffer_9E();
   JS["OBV"] = mm_Buffer_9E();
   JS["MACD"] = mm_Buffer_9E();
   
   return JS;
}
