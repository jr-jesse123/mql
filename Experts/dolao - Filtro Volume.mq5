//+------------------------------------------------------------------+
//|                                                   PrincipeNY.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>

enum ENUM_FiltroVolume
{
   SemFiltro=0,
   Volume_Normal=1,
   Volume_Real=2
};

input int NumeroContratos =5; //nr de contratos para operar
//input double riscoMinimo = 30.00; // O robô só vai operar quando o candle de risco inicial for maior do qu este valor
input double DistanciaAvaliacaoVolue = 2;
input double RelacaoVolumeMinimo = 1;
input double LucroDiario = 3; // tp de cada ação diária, recomendado 10.5
input double RiscoDiario = 4; //SL de cada dia
input int HoraMetodo = 9; //Hora em que o método deve operar
input int MinutoMetodo = 15; //Minuto em que o método deve oeprar
input bool CancelaSegundaOperacao = true; //define se a segunda operação deve ser cancelada
input ENUM_FiltroVolume FiltroPorVolume= Volume_Real;
input ENUM_TIMEFRAMES TimeframeDoVolume = PERIOD_M15;

double volumeToqueMaxima;
double volumeToqueMinima;



MqlRates velas[];            // Variável para armazenar velas
MqlRates velasAuxiliares[];            // Variável para armazenar velas
MqlTick tick;                // variável para armazenar ticks 
MqlDateTime tc;              // variável para capturar Tempo Atual

CTrade trade;                 // Classe com helpers de execução de ordens e posições

double risco;                 // Risco identificado entre a máxima e a mínima da Vela do ponto X
bool AjusteRiscoFeito = false; // Identifica se o ajuste da ordem inversa à primeira operação já foi realizada para compensar o risco
bool PontoDeEntradaExecutado = false; //Identifica se o ponto de entrada já foi posicionado hoje
int dia_ultimoTick;                      //guarda o dia do último tick para identificar passagem entre dias
 double maxima =0;
      double minima =0;

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
   if(trans.order_state == ORDER_STATE_FILLED)
     {/*
         ulong ticket = OrderGetTicket(0);
          trade.OrderDelete(ticket);
               
                 maxima =0;
               minima =0;
               */
               printf("Ordem restante deletada");
               ZerarOrdens(true);
     }
   
/*
   int nrOrdens = OrdersTotal();
   int nrPosicoesDia = PositionsTotal();
   
   //cancela a ordem pendente 
   if(nrOrdens == 1 && nrPosicoesDia == 0)
     {
       ulong ticket = OrderGetTicket(0);
       if(CancelaSegundaOperacao)
         {
               
         }
       
     }  
*/
}

void OnTick()
{  
   datetime hora = TimeCurrent();
   TimeToStruct(hora,tc);
   
   AvaliarVolumeDoMovimento();
   
   

   if (HorarioMetodo(tc, HoraMetodo, MinutoMetodo) && !PontoDeEntradaExecutado)
   {
      SymbolInfoTick(_Symbol,tick);
      CopyRates(_Symbol,_Period,0,4,velas);
      ArraySetAsSeries(velas,true);
      TimeCurrent(tc);
            
       maxima = velas[1].high;
      minima = velas[1].low;
      risco = maxima - minima;
      
     /*if(risco > riscoMinimo && risco < (riscoMinimo + 1)  )*/
        {
            string comentario = TimeCurrent();
            
            volumeToqueMaxima = ObterVolumeDeToqueNaMaxima();
            volumeToqueMinima = ObterVolumeDeToqueNaMinima();
            
            PosicionarOrdens();
            
            
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
     }
     
   dia_ultimoTick = tc.day;  
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

void AvaliarVolumeDoMovimento()
{
   CopyRates(_Symbol, TimeframeDoVolume ,0,2,velasAuxiliares);   
   ArraySetAsSeries(velasAuxiliares,true);
   SymbolInfoTick(_Symbol,tick);
   
   
   
   double volumeParcial = FiltroPorVolume == Volume_Normal ? velasAuxiliares[0].tick_volume : velasAuxiliares[0].real_volume;
   double SegundosTotais = velasAuxiliares[0].time - velasAuxiliares[1].time;
   double SegundosParciais = TimeCurrent() - velasAuxiliares[0].time;
   
   double VolumeProjetado ;
   if(SegundosParciais != 0 && maxima > 0 && minima > 0)
     {
               VolumeProjetado = (SegundosTotais/SegundosParciais) * volumeParcial;   
           
         bool proximidadePrecoMaxima = (maxima <= (tick.last + DistanciaAvaliacaoVolue)) ;
         bool proximidadePrecoMinima = (minima >= (tick.last - DistanciaAvaliacaoVolue)) ;
         
         double RelacaoVolumeAproximacaoMaxima =  VolumeProjetado / volumeToqueMaxima;
         double RelacaoVolumeAproximacaoMinima =  VolumeProjetado / volumeToqueMinima;
         
         
         if(proximidadePrecoMinima)
           {
            bool teste = false;
           }
         
                  
         if(proximidadePrecoMaxima)
           {
            bool teste = false;
           }
         
         if(proximidadePrecoMaxima & RelacaoVolumeAproximacaoMaxima < RelacaoVolumeMinimo & FiltroPorVolume != SemFiltro)
           {
            ZerarOrdens(true);
            printf("Ordens retiradas por falta de volume");
            Alert("Ordens retiradas por falta de volume");
           }
           
         if(proximidadePrecoMinima & RelacaoVolumeAproximacaoMinima < RelacaoVolumeMinimo & FiltroPorVolume != SemFiltro)
           {
            ZerarOrdens(true);
            printf("Ordens retiradas por falta de volume");
            Alert("Ordens retiradas por falta de volume");
           }    
         
         bool PrecoEmZonaDeRevisaoMaxima = (tick.last + DistanciaAvaliacaoVolue  < maxima );
         bool PrecoEmZonaDeRevisaoMinima = (tick.last - DistanciaAvaliacaoVolue  > minima);
         
         double nrOrdens = OrdersTotal();
         /*
         if((nrOrdens == 0) &   PrecoEmZonaDeRevisaoMaxima & PrecoEmZonaDeRevisaoMinima )
           {
               PosicionarOrdens();
           }
           */
   }
   
   
}

double ObterVolumeDeToqueNaMaxima()
{
   CopyRates(_Symbol,TimeframeDoVolume,0,15,velasAuxiliares);
   
   
   
   for(int i=0;i<ArraySize(velasAuxiliares);i++)
     {
      
      if(maxima == velasAuxiliares[i].high)
        {
            double volume = FiltroPorVolume == Volume_Normal ? velasAuxiliares[i].tick_volume : 
               velasAuxiliares[i].real_volume;
            return volume;
        }
     }
     
     return 0;
}


double ObterVolumeDeToqueNaMinima()
{
   CopyRates(_Symbol,TimeframeDoVolume,0,15,velasAuxiliares);
   
   for(int i=0;i<ArraySize(velasAuxiliares);i++)
     {
      if(minima == velasAuxiliares[i].low)
        {
            double volume = FiltroPorVolume == Volume_Normal ? velasAuxiliares[i].tick_volume : 
               velasAuxiliares[i].real_volume;
               
            return volume;
        }
     }
     
     return 0;
}

void ZerarOrdens(bool Finalizar)
{

               double nrOrdens = OrdersTotal();
               for(int i=0;i<nrOrdens;i++)
                 {
                     ulong ticket = OrderGetTicket(0);
                     trade.OrderDelete(ticket);
                 }
                 
                 
                 if(Finalizar)
                   {
                                     
                       maxima = 0;
                       minima = 0;

                   }
}

void PosicionarOrdens()
{
   bool sucessBuy = trade.BuyStop(NumeroContratos, maxima, _Symbol, maxima - RiscoDiario, maxima + LucroDiario, ORDER_TIME_DAY,0);
   bool sucessSell = trade.SellStop(NumeroContratos, minima, _Symbol, minima + RiscoDiario , minima - LucroDiario, ORDER_TIME_DAY,0);
            
   if(!sucessBuy | !sucessSell)
     {
        ZerarOrdens(true);
          printf("Ordens não posicionadas devido ao rápido deslize do preço");
     }         
}
