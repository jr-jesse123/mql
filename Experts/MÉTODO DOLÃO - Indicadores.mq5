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


input int NumeroContratos =5; //nr de contratos para operar
input double riscoMinimo = 0; // O robô só vai operar quando o candle de risco inicial for maior do qu este valor
input double riscoMaximo = 200; // O robô só vai operar quando o candle de risco inicial for menor do qu este valor

input double LucroDiario = 3; // tp de cada ação diária, recomendado 10.5
input double RiscoDiario = 4; //SL de cada dia
input int HoraMetodo = 9; //Hora em que o método deve operar
input int MinutoMetodo = 15; //Minuto em que o método deve oeprar
input bool CancelaSegundaOperacao = true; //define se a segunda operação deve ser cancelada
input double DistanciaSLMOvel =2; //Define a Distancia do StopLoss Para o preco


int MM_Handle_9;
int MM_Handle_21;
int MM_Handle_200;

double MM_Buffer[];


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
double buffer_line[]/*Data Buffer*/, buffer_color_line[]/*Color index buffer*/;



void OnTick()
{  
   GerenciarVendas();
   
   
   if(DistanciaSLMOvel > 0)
     {
      if(PositionsTotal() > 0)
        {
           ulong ticket =  PositionGetTicket(0);
           SymbolInfoTick(_Symbol,tick);
           double sl_Atual = PositionGetDouble(POSITION_SL);
           double tp = PositionGetDouble(POSITION_SL);
       
         if(PositionsTotal() > 0)
         {
               ulong ticket =  PositionGetTicket(0);
              SymbolInfoTick(_Symbol,tick);
               double sl_Atual = PositionGetDouble(POSITION_SL);
               double tp = PositionGetDouble(POSITION_TP);
       
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {
                     if(tick.last - sl_Atual > DistanciaSLMOvel)
                       {
                           trade.PositionModify(ticket, tick.last - DistanciaSLMOvel, tp);
                       }
                     
                 }
                 else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                        {
                               if( sl_Atual - tick.last  > DistanciaSLMOvel)
                             {
                                 double novo_sl=tick.last + DistanciaSLMOvel;
                                 
                                 trade.PositionModify(ticket, novo_sl , tp);
                             }
                        }
         }
        
           
        
        
        }
     }
}






int OnInit()
  {
   
   
   MM_Handle_9 = iMA(_Symbol, _Period,9,0,MODE_SMA,PRICE_CLOSE);
   
   
   MM_Handle_21 = iMA(_Symbol, _Period,21,0,MODE_SMA,PRICE_CLOSE);
   MM_Handle_200 = iMA(_Symbol, _Period,200,0,MODE_SMA,PRICE_CLOSE);
   
   
   if(MM_Handle_200 < 0 || MM_Handle_21 < 0 || MM_Handle_9 <0)
     {
         Alert("Erro ao carregar handle do indicador");
         return -1;
     }
   
   ChartIndicatorAdd(0,0,MM_Handle_200);
   ChartIndicatorAdd(0,0,MM_Handle_21);
   ChartIndicatorAdd(0,0,MM_Handle_9);
   
   
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
       if(CancelaSegundaOperacao)
         {
                trade.OrderDelete(ticket);
               printf("Ordem restante deletada");
         }
       
     }  
}

//+------------------------------------------------------------------+

void GerenciarVendas()
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
      
     if(risco > riscoMinimo && risco < (riscoMinimo +2.5) )
        {
            string comentario = TimeCurrent();
            
            bool sucess = trade.BuyStop(NumeroContratos, maxima, _Symbol, maxima - RiscoDiario, maxima + LucroDiario, ORDER_TIME_DAY,0,comentario);
            
              double peso = .5;
            /*while(!sucess)
              {
                 sucess = trade.BuyStop(NumeroContratos, maxima + peso, _Symbol, maxima - RiscoDiario, maxima + LucroDiario, ORDER_TIME_DAY,0,comentario);
                  peso = peso +.5;
              }*/
            sucess = trade.SellStop(NumeroContratos, minima, _Symbol, minima + RiscoDiario , minima - LucroDiario, ORDER_TIME_DAY,0,comentario);
            
                    peso = .5;
            /*while(!sucess)
              {
                    sucess = trade.SellStop(NumeroContratos , minima - peso, _Symbol, minima + RiscoDiario , minima - LucroDiario, ORDER_TIME_DAY,0,comentario);
                     peso = peso +.5;
              }
            */
            
            AjusteRiscoFeito = false;
            PontoDeEntradaExecutado = true;
       }
   }
  VerificarMudancaDeDiaEAlterarPontoDeEntrada();
   }

void VerificarMudancaDeDiaEAlterarPontoDeEntrada()
{
 if(tc.day != dia_ultimoTick && PontoDeEntradaExecutado)
     {
         printf("Novo Dia de Transação, Disparar Ponto de entrada");
         PontoDeEntradaExecutado = false;
         EncerrarPosicoes();
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
      if(DateTimeDaVela.min < min || DateTimeDaVela.hour < hora)
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

