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


input int NrContratos = 1;
input int nrVelasAnalise = 4; // Número de velas a serem analisadas;
input double CurvaMinima = .5;
input int  CruzamentosParaLateralizacao = 3;
input double FolgaStopLoss = 2;


enum Direcao
  {
   Ascendente,
   Descendente,
   Lateral
  };

Direcao DirecaoAnterior = Lateral;



#include <Indicadores.mqh>
#include <Trade/Trade.mqh>
#include <CSerializadorDeVela.mqh>
#include <CDEtectorDeNovaVela.mqh>
Indicadores Ind(true, false, false, false, false, false, false);
CTrade trade;
CDetectorDeNovaVela DNV;

int OnInit()
  {
//---
   
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
   if(DNV.TemosNovaVela())
     {
      
         double media[] ;
         
         Ind.mm_Buffer_9E(media, 0,1,nrVelasAnalise);
      
         Direcao _direcaoAtaul = ObterUltimaDirecao(media,DirecaoAnterior);
         
         
         bool GatilhoEnderada = _direcaoAtaul != Lateral & _direcaoAtaul != DirecaoAnterior;
         
         if(GatilhoEnderada)
           {
               int iv = nrVelasAnalise -1; // Indice 
               ZerarPosicoesEOrdens();
               CSerializadorDeVela vela(nrVelasAnalise);
               double entrada = _direcaoAtaul == Ascendente ? vela.MR[1].high : 
                  vela.MR[1].low;
               double SL = _direcaoAtaul == Ascendente ? vela.MR[1].low - FolgaStopLoss :
                   vela.MR[1].high + FolgaStopLoss;
               
               if(_direcaoAtaul == Ascendente)
                 {
                     SL = SL < media[1] ? SL : media[0] - FolgaStopLoss;
                 }
          else if(_direcaoAtaul == Descendente)
                 {
                     SL = SL > media[1] ? SL : media[0] + FolgaStopLoss;
                 }
               
               if(_direcaoAtaul == Ascendente)
                 {
                  trade.BuyStop(1,entrada,_Symbol,SL,0);
                 }
            else if(_direcaoAtaul == Descendente)
                   {
                    trade.SellStop(1,entrada,_Symbol,SL,0);
                   }
           }
         
         DirecaoAnterior = _direcaoAtaul;
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