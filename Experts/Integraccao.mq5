//+------------------------------------------------------------------+
//|                                                 ColetorTicks.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <JAson.mqh>
#include <CDetectorDeNovaVela.mqh>
#include <CSerializadorDeVela.mqh>
#include <UrlBuilder.mqh>
#include <Indicadores.mqh>

#import "restmql_x64.dll"
   string Get(string url);
   string Post(string url, string data);
#import


Indicadores ind;

  
  
  
//string in,out;
//CJAVal js(NULL,jtUNDEF); 



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  
  
  
  
  int segundos = PeriodSeconds();
   //string teste = Get("http://127.0.0.1:5000/WeatherForecast");
   //string teste2 = Post("http://127.0.0.1:5000/WeatherForecast?objeto='fesfesf'","");
  
  
  
 
    
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

  
  
  if(CDetectorDeNovaVela::TemosNovaVela())
    {
      CSerializadorDeVela CV();
      string Vela = CV.ObterVelaSerializada();
      
      /*
      CopyBuffer(Indicadores::mm_Handle_9E,0,0,1,mm_Buffer_9E);
      CopyBuffer(Indicadores::mm_Handle_21,0,0,1,mm_Buffer_21);
      CopyBuffer(Indicadores::mm_Handle_80,0,0,1,mm_Buffer_80);
      CopyBuffer(Indicadores::mm_Handle_200,0,0,1,mm_Buffer_200);
      CopyBuffer(Indicadores::mm_Handle_400,0,0,1,mm_Buffer_400);
      CopyBuffer(Indicadores::obv_Handle,0,0,1,obv_Buffer);
        */
      UrlBuilder ub;
      ub.AddParameter("Vela", Vela);
      ub.AddParameter("MM9E",ind.mm_Buffer_9E());
      ub.AddParameter("MM21",ind.mm_Buffer_21());
      ub.AddParameter("MM80",ind.mm_Buffer_80());
      ub.AddParameter("MM200",ind.mm_Buffer_200());
      ub.AddParameter("MM400",ind.mm_Buffer_400());
      ub.AddParameter("OBV",ind.obv_Buffer());
      ub.AddParameter("OBV",ind.MACD_Buffer());
      
      string url = ub.ObterUrl();
      printf(url);
      
      string resp =  Post(url, "");
      
    }
  }
//+------------------------------------------------------------------+


