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
    
      
      CSerializadorDeVela CV(1);
      UrlBuilder ub;
      string Vela = CV.ObterVelaSerializada();
      
      ub.AddParameter("vela", Vela);
      ub.AddParameter("timeFrame", PeriodSeconds());
      ub.AddParameter("symbol", _Symbol);
      
      
      string url = ub.ObterUrl();
      printf(url);
      
      string resp =  Post(url, "");
      
      
      if(resp != "204")
        {
            Alert(resp);
        }
    }
  }
//+------------------------------------------------------------------+


