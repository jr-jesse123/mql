//+------------------------------------------------------------------+
//|                                                 ColetorTicks.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
input string nomeArquivo = "teste" ;//  Nome da tabela onde serão salvas as informações capturadas

#import "restmql.dll"
   int CPing(string &str);
   string CPing2();
   string Get(string url);
   string Post(string url, string data);
   void Teste(MqlTick &tick);
#import


struct teste
  {
      int teste1;
      string nome2;
      
  };


//#include <dlls\dllmain.cpp>



int db;
int File;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
      string teste = " comunicado importante: \n nova linha";
      printf(CPing2());
      Print(Get("https://httpbin.org/get"));
      printf(teste);
    File =  FileOpen(nomeArquivo, FILE_COMMON | FILE_WRITE | FILE_CSV, ";",CP_UTF8 );
    
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   FileClose(File);
   
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
  
   Teste(tick);
   
   MqlDateTime date;
   TimeToStruct(tick.time, date);
   
   FileWrite(File, date.year,date.mon, date.day,date.hour,date.min, date.sec  , tick.ask, tick.bid, tick.last, tick.time_msc, tick.volume, tick.volume_real, tick.flags);
   
  }
//+------------------------------------------------------------------+
