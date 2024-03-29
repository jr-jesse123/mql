//+------------------------------------------------------------------+
//|                                                          9_1.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <DetectorDeHorario.mqh>

enum OpcoesSL
  {
      Candle_de_Entrada, //
      Fundo_Topo_Anterior,
      Candle_de_Entrada_ou_CandleAtivador
  };

enum FiltroDeEntrada
  {
      nenhum,
      DivergenciaIFR
  };

input FiltroDeEntrada FiltroEntrada = nenhum;
input OpcoesSL ModoSL = Candle_de_Entrada;
input int NrContratos = 1;
input int nrVelasAnalise = 4; // Número de velas a serem analisadas;
input double CurvaMinima = .5;
input int  CruzamentosParaLateralizacao = 3;
input double FolgaStopLoss = 2;
input double lucrovsrisco = 1;

enum Direcao
  {
   Ascendente,
   Descendente,
   Lateral
  };

Direcao DirecaoAnterior = Lateral;
CDetectorDeHorario Relogio;


#include <Indicadores.mqh>
#include <Trade/Trade.mqh>
#include <CSerializadorDeVela.mqh>
#include <CDEtectorDeNovaVela.mqh>
#include <DetectorDeHorario.mqh>
Indicadores Ind(true, true, false, false, false, false, false);
CTrade trade;
CDetectorDeNovaVela DNV;
CDetectorDeHorario HorarioManager;

int OnInit()
  {
//---
   EventSetTimer(30);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      ZerarPosicoesEOrdens();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double mediaDeslocada[] ;
   Ind.mm_Buffer_9E(mediaDeslocada, 0,1,nrVelasAnalise);
   double mediaDescolada21[];
   Ind.mm_Buffer_21(mediaDescolada21, 0,1,nrVelasAnalise);
   
   if(DNV.TemosNovaVela())
     {
      
         
         
         Ind.mm_Buffer_9E(mediaDeslocada, 0,1,nrVelasAnalise);
      
         Direcao _direcaoAtaul = ObterUltimaDirecao(mediaDeslocada,DirecaoAnterior);
         
         
         bool GatilhoEnderada = _direcaoAtaul != Lateral & _direcaoAtaul != DirecaoAnterior;
         
         CSerializadorDeVela vela(nrVelasAnalise);
         if(GatilhoEnderada)
           {
               int iv = nrVelasAnalise -1; // Indice 
               ZerarPosicoesEOrdens();
               
               
               double SL = ObterStopLoss(_direcaoAtaul,vela.MR[0],mediaDeslocada);
               
               
               double entrada = _direcaoAtaul == Ascendente ? vela.MR[0].high : 
                  vela.MR[0].low;
               
               
               
          
               datetime hora = TimeCurrent();
                 MqlDateTime dt;
                 TimeToStruct(hora,dt);
                 
                 //bool horario = dt.hour > 9 && dt.hour < 11;
                 
                 
               
               if(_direcaoAtaul == Ascendente )
                 {
                 //double tp = (entrada - SL) * lucrovsrisco;
                  trade.BuyStop(1,entrada,_Symbol,SL,0);
                 }
            else if(_direcaoAtaul == Descendente )
                   {
                   //double tp = ( SL - entrada ) * lucrovsrisco;
                    trade.SellStop(1,entrada,_Symbol,SL,0);
                   }
           }
         DirecaoAnterior = _direcaoAtaul;
         
         if(PositionsTotal() > 0)
           {
               AjustarStopLoss(_direcaoAtaul,vela.MR[1],mediaDeslocada);   
           }
         
         
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
  

//+------------------------------------------------------------------+


bool mercadoLateralizado(double &media[])
{
   int reversoes;
   Direcao _direcaoAnterior;
   double subarray[];
   
   for(int i=0;i<ArraySize(media)-1;i++)
     {
         ArrayCopy(subarray,media,0,i,2);
         Direcao _direcaoAtual = ObterUltimaDirecao(subarray, _direcaoAnterior);     
         if(_direcaoAtual != DirecaoAnterior)
           {
               reversoes++;
           }
     }
     
     if(reversoes > CruzamentosParaLateralizacao)
       {
         return true;
       }else
          {
           return false;
          }
}

Direcao ObterUltimaDirecao(double &media[], Direcao direcaoAnterior) 
{
   bool CurvaParaCima =  media[0] > (media[1] + CurvaMinima);
   bool CurvaParaBaixo = media[0] < (media[1] - CurvaMinima);
   
   
   
   return CurvaParaCima ? Ascendente : CurvaParaBaixo ? Descendente : direcaoAnterior;
   
}

void ZerarPosicoesEOrdens()
{
int NrOrdens = OrdersTotal();
      
      for(int i=0;i<NrOrdens;i++)
        {
            ulong ticket = OrderGetTicket(0);
            trade.OrderDelete(ticket);
        }
        
        int NrPosicoes = PositionsTotal();
        for(int i=0;i<NrPosicoes;i++)
          {
            ulong ticket = PositionGetTicket(0);
            trade.PositionClose(ticket);
          }
}

void AjustarStopLoss(Direcao _direcaoAtaul, MqlRates &UltimaVelaFechada, double &media[])
{
   ulong ticket = PositionGetTicket(0);
   
   double sl = PositionGetDouble(POSITION_SL);
   
   
   double nv_sl = ObterStopLoss(_direcaoAtaul, UltimaVelaFechada,media);
   
   if(sl != nv_sl)
     {
      bool suces = trade.PositionModify(ticket,nv_sl,0);   
   
   
   
   
   if(!suces)
     {
      int teste = 1;
      
      printf(GetLastError());
     }
     }
   
   
   
   
}


double ObterStopLoss(Direcao _direcaoAtaul, MqlRates &UltimaVelaFechada, double &media[])
{

               double SL = _direcaoAtaul == Ascendente ? UltimaVelaFechada.low - FolgaStopLoss :
                   UltimaVelaFechada.high + FolgaStopLoss;
                   
                        if(_direcaoAtaul == Ascendente)
                 {
                     SL = SL < media[0] ? SL : media[0] - FolgaStopLoss;
                 }
          else if(_direcaoAtaul == Descendente)
                 {
                     SL = SL > media[0] ? SL : media[0] + FolgaStopLoss;
                 }
                 printf("Novo SL: " + DoubleToString(SL));
                   return SL;
}

void OnTimer()
  {
      if(HorarioManager.DetectarHorario(17,45))
        {
         ZerarPosicoesEOrdens();
        } 
  }