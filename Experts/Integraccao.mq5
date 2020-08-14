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
#include <ContextoDeVela.mqh>

#import "restmql_x64.dll"
   string Get(string url);
   string Post(string url, string data);
#import

//string in,out;
//CJAVal js(NULL,jtUNDEF); 

   

int mm_Handle_9E;
int mm_Handle_21;
int mm_Handle_80;
int mm_Handle_200;
int mm_Handle_400;
int obv_Handle;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  bool suces = MarketBookAdd(_Symbol);
  
  int segundos = PeriodSeconds();
   //string teste = Get("http://127.0.0.1:5000/WeatherForecast");
   //string teste2 = Post("http://127.0.0.1:5000/WeatherForecast?objeto='fesfesf'","");
  
obv_Handle = iOBV(_Symbol, _Period,VOLUME_REAL);
  mm_Handle_9E = iMA(_Symbol, _Period,9,0,MODE_EMA,PRICE_CLOSE);
  mm_Handle_21 = iMA(_Symbol, _Period,21,0,MODE_SMA,PRICE_CLOSE);
  mm_Handle_80 = iMA(_Symbol, _Period,80,0,MODE_SMA,PRICE_CLOSE);
  mm_Handle_200 = iMA(_Symbol, _Period,200,0,MODE_SMA,PRICE_CLOSE);
  mm_Handle_400 = iMA(_Symbol, _Period,400,0,MODE_SMA,PRICE_CLOSE);
  
  if(mm_Handle_9E < 0 ||mm_Handle_21 < 0|| mm_Handle_80 < 0||mm_Handle_200 < 0||mm_Handle_400 < 0)
    {
      Alert("Erro ao carregar Indicar  - ", GetLastError());
      return(-1);
    }
    
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
      ContextoDeVela CV();
      string teste = CV.ObterJsonString();
      
      UrlBuilder ub;
      ub.AddParameter("objeto", teste);
      string url = ub.ObterUrl();
      printf(url);
      
      string resp =  Post(url, "");
      2 +2;
    }
  }
//+------------------------------------------------------------------+


   
  class UrlBuilder
    {
  public:
               UrlBuilder(){baseUrl = "http://127.0.0.1:5000/WeatherForecast"; actualUrl = baseUrl;} ;             
      void AddParameter(string nome, string valor);
      string ObterUrl(){return actualUrl;};
  private:
   string baseUrl ;
   string actualUrl;
    };
    
    
void  UrlBuilder::AddParameter(string nome,string valor) 
{
   if(actualUrl == baseUrl)
     {
         actualUrl = actualUrl + "?" + nome + "=" + valor;
     }else
        {
         actualUrl = actualUrl + "&" + nome + "=" + valor;
        }
}
