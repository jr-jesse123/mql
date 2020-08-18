//+------------------------------------------------------------------+
//|                                                   UrlBuilder.mqh |
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

   
  class UrlBuilder
    {
  public:
               UrlBuilder(){baseUrl = "http://127.0.0.1:5000/SalvarVela"; actualUrl = baseUrl;} ;             
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
