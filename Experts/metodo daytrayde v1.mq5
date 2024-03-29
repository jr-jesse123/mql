//+------------------------------------------------------------------+
//|                                                   PrincipeNY.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
#include <Helpers.mqh>


input int NumeroContratos =1; //nr de contratos para operar
input double riscoMinimo = 30.00; // O robô só vai operar quando o candle de risco inicial for maior do qu este valor
input double LucroDiario = 10; // tp de cada ação diária, recomendado 10.5
input int HoraMetodo = 9; //Hora em que o método deve operar
input int MinutoMetodo = 15; //Minuto em que o método deve oeprar

MqlRates velas[];            // Variável para armazenar velas
MqlTick tick;                // variável para armazenar ticks 
MqlDateTime tc;              // variável para capturar Tempo Atual

CTrade trade;                 // Classe com helpers de execução de ordens e posições
int ny_Handle;               //Handle do  indicador principe de nova York
double risco;                 // Risco identificado entre a máxima e a mínima da Vela do ponto X
bool AjusteRiscoFeito = false; // Identifica se o ajuste da ordem inversa à primeira operação já foi realizada para compensar o risco
bool PontoDeEntradaExecutado = false; //Identifica se o ponto de entrada já foi posicionado hoje
int dia_ultimoTick;                      //guarda o dia do último tick para identificar passagem entre dias
int MesAtual;                    //guarda o mês atual para sabermos quando houve troca de mês.
int db;
int file;
bool prejuizo1 =false;
bool prejuizo2 = false;
ulong Operacao1;
ulong Operacao2;
double SaldoAntesDaOperacao;

int OnInit()
  {
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   
  }



void OnTradeTransaction(const MqlTradeTransaction& trans,
                             const MqlTradeRequest& request,
                             const MqlTradeResult& result)
{

   int nrOrdens = OrdersTotal();
   int nrPosicoesDia = ObeterPosicoesDoDia();
   
   //realiza o ajuste do risco da segunda operação do método
   if(nrOrdens == 1 && nrPosicoesDia ==1 && !AjusteRiscoFeito)
     {
          AjustarOrdem(risco);
          AjusteRiscoFeito = true;
     }

     
   //cancela a ordem pendente caso haja lucro de primeira  
   if(nrOrdens == 1 && nrPosicoesDia == 0)
     {
       ulong ticket = OrderGetTicket(0);
       trade.OrderDelete(ticket);
       
       printf("Ordem restante deletada");
     }  
}

void OnTick()
{  
   datetime hora = TimeCurrent();
   TimeToStruct(hora,tc);

   if (HorarioMetodo(tc, HoraMetodo, MinutoMetodo) && !PontoDeEntradaExecutado)
   {
   
      
      SymbolInfoTick(_Symbol,tick);
      CopyRates(_Symbol,_Period,0,4,velas);
      ArraySetAsSeries(velas,true);
      TimeCurrent(tc);
            
      double maxima = velas[1].high;
      double minima = velas[1].low;
      risco = maxima - minima;
      
     /*if(risco > riscoMinimo && risco < (riscoMinimo + 1)  )*/
        {
 
            string comentario = TimeCurrent();
            
            int nrContratos;
            
            if(prejuizo1 && prejuizo2)
              {
               nrContratos = 13;
               prejuizo1 = false;
               prejuizo2 = false;
              }
              else if(prejuizo1)
                     {
                      nrContratos = 4;
                     }
                     else
                       {
                        nrContratos = 1;
                       }
            
            
            bool success =  trade.BuyStop(nrContratos, maxima + 0.5 , _Symbol, minima -0.5, maxima + LucroDiario, ORDER_TIME_DAY,0,comentario);
            
            
            double peso = 1;
            while(!success)
              {
               success = trade.BuyStop(nrContratos, maxima + peso , _Symbol, minima -0.5, maxima + LucroDiario, ORDER_TIME_DAY,0,comentario);
               peso = peso + .5;
              }
            
            
            
            success = trade.SellStop(nrContratos, minima  - 0.5 , _Symbol, maxima +0.5 , minima - LucroDiario, ORDER_TIME_DAY,0,comentario);
            
            peso = 1;
            while(!success)
              {
               success = trade.SellStop(nrContratos, minima  - peso , _Symbol, maxima +0.5 , minima - LucroDiario, ORDER_TIME_DAY,0,comentario);
               peso = peso + .5;
              }
            
            
            SaldoAntesDaOperacao = AccountInfoDouble(ACCOUNT_BALANCE);
            
            AjusteRiscoFeito = false;
            PontoDeEntradaExecutado = true;
       }
       
       
   }
  VerificarMudancaDeDiaEAlterarPontoDeEntrada();
}

//+------------------------------------------------------------------+



void VerificarMudancaDeDiaEAlterarPontoDeEntrada()
{
 if(tc.day != dia_ultimoTick && PontoDeEntradaExecutado)
     {
         printf("Novo Dia de Transação, Disparar Ponto de entrada");
         PontoDeEntradaExecutado = false;
         EncerrarPosicoes();
         bool prejuizo = VerificarSeHouvePrejuizo();
         
         if(prejuizo && prejuizo1)
           {
            prejuizo2 = true;
           }
           else if(prejuizo)
                  {
                   prejuizo1 = true;
                  }
                  else
                    {
                     prejuizo1 = false;
                     prejuizo2 = false;
                    }
         
     }
     
   dia_ultimoTick = tc.day;  
}

int ObeterPosicoesDoDia()
{
   int Countagem= 0;
   for(int i=0;i<PositionsTotal();i++)
     {
         //PositionSelect(_Symbol);
         PositionGetSymbol(i);
        datetime today=TimeCurrent()-TimeCurrent()%86400;
        datetime aberturaPosicao =  PositionGetInteger(POSITION_TIME);
        if(today < aberturaPosicao)
          {
            Countagem ++;
          }
     }
     
     if(Countagem > 2)
       {
        printf("Contratos Acumulados");
        printf(IntegerToString(Countagem));
       }
     
     return Countagem;
}


bool InicioMes()
{
   bool virada = MesAtual != tc.mon;
   if(virada)
     {
         int t = 2+2;
     }
   MesAtual = tc.mon;
   return virada;
}

double ObterLucroDePosicoes()
{
   double Total = 0;
   for(int i=0;i<PositionsTotal();i++)
     {
         
         ulong ticket= PositionGetTicket(i);
         
         double LucroAtual = PositionGetDouble(POSITION_PROFIT);  
         Total = Total + LucroAtual;
     }
     return Total;
}

void EncerrarPosicoes()
{
   for(int i=0;i<PositionsTotal();i++)
     {
          PositionSelect(i);
          ulong ticket = PositionGetInteger(POSITION_TICKET);
          trade.PositionClose(ticket);
      }
      
      //MqlTradeRequest
      //MqlTradeResult
      //Order
}      



bool HorarioMetodo(MqlDateTime &tc, int hora, int min) 
{
   MqlDateTime DateTimeDaVela;
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);
   TimeToStruct(velas[1].time,DateTimeDaVela);

   if(tc.hour == hora && tc.min == min)
     {
      if(DateTimeDaVela.min < min)
        {
         return true;
        }
        else
          {
           return false;
          }
     }
     else
       {
        return false;
       }
}


void AjustarOrdem(double risco) 
{

   ulong ticket =  OrderGetTicket(0);
   
   double price = OrderGetDouble(ORDER_PRICE_OPEN);
   double tp = OrderGetDouble(ORDER_TP);
   double sl = OrderGetDouble(ORDER_SL);
   ENUM_ORDER_TYPE tipo =  OrderGetInteger(ORDER_TYPE);
   datetime expiration = OrderGetInteger(ORDER_TIME_EXPIRATION);
   
   
   double novo_sl;
   
   if(tipo == ORDER_TYPE_BUY_STOP)
     {
         novo_sl = price - risco;
     }
     else
       {
         novo_sl = price + risco;
       }
   
   double novo_tp;
   
     
   if(tipo == ORDER_TYPE_BUY_STOP)
     {
         novo_tp = tp + risco + LucroDiario;
     }
     else
       {
         novo_tp = price - risco - LucroDiario;
       }
   
   
   trade.OrderModify(ticket, price,novo_sl,novo_tp, ORDER_TIME_DAY, expiration);
}



bool VerificarSeHouvePrejuizo() 
{
   
   double saldoAtual = AccountInfoDouble(ACCOUNT_BALANCE);
   
   if(saldoAtual < SaldoAntesDaOperacao)
     {
      return true;
     }
     else
       {
        return false;
       }
}
