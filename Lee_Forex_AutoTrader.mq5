//+------------------------------------------------------------------+
//|                  Lee_Forex_AutoTrader.mq5                        |
//|                  Lee Forex AutoTrader                            |
//|                  DEMO TESTING ONLY                                |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "Lee Forex AutoTrader - EMA, RSI and ATR strategy"

#include <Trade/Trade.mqh>

CTrade trade;

//========================= INPUT SETTINGS ==========================

input double RiskPercent          = 0.5;
input double DailyLossLimitPct    = 2.0;
input int    MaxOpenPositions     = 3;

input int    FastEMA              = 20;
input int    SlowEMA              = 50;
input int    RSIPeriod            = 14;
input int    ATRPeriod            = 14;

input double RSI_Buy_Min          = 50.0;
input double RSI_Buy_Max          = 70.0;
input double RSI_Sell_Min         = 30.0;
input double RSI_Sell_Max         = 50.0;

input double ATR_StopMultiplier   = 2.0;
input double RewardRiskRatio      = 1.5;

input ENUM_TIMEFRAMES SignalTimeframe = PERIOD_H1;

input ulong  MagicNumber          = 68102601;
input int    MaxSpreadPoints      = 30;
input int    SlippagePoints       = 20;

// Add broker-specific symbols exactly as shown in Market Watch.
// This list is a starting point; verify every symbol with your broker.
input string TradingSymbols =
"EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,USDCAD,NZDUSD";

//========================= GLOBAL VARIABLES ========================

string Symbols[];
datetime LastBarTime[];
int FastEMAHandles[];
int SlowEMAHandles[];
int RSIHandles[];
int ATRHandles[];

int SymbolCount = 0;

int DayKey = -1;
double DayStartEquity = 0.0;
bool DailyLimitReached = false;

//========================= DATE HELPERS ============================

int GetDayKey(datetime timeValue)
{
   MqlDateTime dt;
   TimeToStruct(timeValue, dt);

   return dt.year * 10000 + dt.mon * 100 + dt.day;
}

//========================= SYMBOL HELPERS ==========================

string CleanSymbol(string value)
{
   StringTrimLeft(value);
   StringTrimRight(value);
   return value;
}

bool IsOurPosition(ulong ticket)
{
   if(!PositionSelectByTicket(ticket))
      return false;

   if((ulong)PositionGetInteger(POSITION_MAGIC) != MagicNumber)
      return false;

   return true;
}

bool IsSymbolAlreadyTraded(string symbol)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(!IsOurPosition(ticket))
         continue;

      if(PositionGetString(POSITION_SYMBOL) == symbol)
         return true;
   }

   return false;
}

int CountOurPositions()
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(IsOurPosition(ticket))
         count++;
   }

   return count;
}

//========================= DAILY RISK ==============================

void UpdateDailyRisk()
{
   datetime now = TimeCurrent();
   int today = GetDayKey(now);

   if(today != DayKey)
   {
      DayKey = today;
      DayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      DailyLimitReached = false;

      Print("Lee AutoTrader: new trading day. Starting equity = ",
            DoubleToString(DayStartEquity, 2));
   }

   if(DayStartEquity <= 0.0)
      return;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   double lossPercent =
      ((DayStartEquity - equity) / DayStartEquity) * 100.0;

   if(lossPercent >= DailyLossLimitPct)
   {
      DailyLimitReached = true;

      Print("Lee AutoTrader: daily loss limit reached. ",
            "No new trades will be opened.");
   }
}

//========================= INDICATOR DATA ===========================

bool ReadBufferValue(int handle, int bufferNumber, int shift,
                     double &value)
{
   if(handle == INVALID_HANDLE)
      return false;

   double values[];
   ArraySetAsSeries(values, true);

   if(CopyBuffer(handle, bufferNumber, shift, 1, values) != 1)
      return false;

   value = values[0];

   if(value == EMPTY_VALUE || !MathIsValidNumber(value))
      return false;

   return true;
}

//========================= LOT CALCULATION ==========================

double CalculateVolume(string symbol, double stopDistance)
{
   if(stopDistance <= 0.0)
      return 0.0;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney = equity * RiskPercent / 100.0;

   if(equity <= 0.0 || riskMoney <= 0.0)
      return 0.0;

   double tickSize =
      SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

   double tickValueLoss =
      SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);

   if(tickValueLoss <= 0.0)
      tickValueLoss = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   double volumeMin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double volumeMax = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   if(tickSize <= 0.0 || tickValueLoss <= 0.0 ||
      volumeMin <= 0.0 || volumeMax <= 0.0 || volumeStep <= 0.0)
   {
      Print("Lee AutoTrader: invalid symbol risk data for ", symbol);
      return 0.0;
   }

   double lossPerLot =
      (stopDistance / tickSize) * tickValueLoss;

   if(lossPerLot <= 0.0)
      return 0.0;

   double volume = riskMoney / lossPerLot;

   // Round DOWN so the requested risk is not increased by rounding.
   volume = MathFloor(volume / volumeStep) * volumeStep;

   volume = MathMin(volume, volumeMax);

   // Do not force the broker minimum if it exceeds the risk budget.
   if(volume < volumeMin)
   {
      Print("Lee AutoTrader: minimum lot would exceed risk budget for ",
            symbol, ". Trade skipped.");
      return 0.0;
   }

   int volumeDigits = 0;
   double step = volumeStep;

   while(volumeDigits < 8 &&
         MathAbs(step - MathRound(step)) > 0.00000001)
   {
      step *= 10.0;
      volumeDigits++;
   }

   return NormalizeDouble(volume, volumeDigits);
}

//========================= SPREAD FILTER ============================

bool SpreadIsAcceptable(string symbol)
{
   MqlTick tick;

   if(!SymbolInfoTick(symbol, tick))
      return false;

   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

   if(point <= 0.0)
      return false;

   double spreadPoints = (tick.ask - tick.bid) / point;

   if(spreadPoints > MaxSpreadPoints)
      return false;

   return true;
}

//========================= NEW BAR CHECK ============================

bool IsNewBar(int index)
{
   datetime barTime = iTime(Symbols[index], SignalTimeframe, 0);

   if(barTime <= 0)
      return false;

   if(LastBarTime[index] == 0)
   {
      LastBarTime[index] = barTime;
      return false;
   }

   if(barTime != LastBarTime[index])
   {
      LastBarTime[index] = barTime;
      return true;
   }

   return false;
}

//========================= TRADING SIGNAL ===========================

void CheckSymbol(int index)
{
   string symbol = Symbols[index];

   if(DailyLimitReached)
      return;

   if(CountOurPositions() >= MaxOpenPositions)
      return;

   // Avoid duplicate positions on the same symbol.
   if(IsSymbolAlreadyTraded(symbol))
      return;

   if(!SpreadIsAcceptable(symbol))
      return;

   double fastEMA, slowEMA, rsi, atr;

   // Use the last completed candle (shift 1).
   if(!ReadBufferValue(FastEMAHandles[index], 0, 1, fastEMA))
      return;

   if(!ReadBufferValue(SlowEMAHandles[index], 0, 1, slowEMA))
      return;

   if(!ReadBufferValue(RSIHandles[index], 0, 1, rsi))
      return;

   if(!ReadBufferValue(ATRHandles[index], 0, 1, atr))
      return;

   if(atr <= 0.0)
      return;

   bool buySignal =
      fastEMA > slowEMA &&
      rsi >= RSI_Buy_Min &&
      rsi <= RSI_Buy_Max;

   bool sellSignal =
      fastEMA < slowEMA &&
      rsi >= RSI_Sell_Min &&
      rsi <= RSI_Sell_Max;

   if(!buySignal && !sellSignal)
      return;

   MqlTick tick;

   if(!SymbolInfoTick(symbol, tick))
      return;

   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   if(point <= 0.0)
      return;

   double stopDistance = atr * ATR_StopMultiplier;

   long stopLevelPoints =
      SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);

   double minimumStopDistance = stopLevelPoints * point;

   if(stopDistance < minimumStopDistance)
      stopDistance = minimumStopDistance;

   // Add a small distance to help meet broker stop requirements.
   stopDistance = MathMax(stopDistance, 2.0 * point);

   double volume = CalculateVolume(symbol, stopDistance);

   if(volume <= 0.0)
      return;

   double sl = 0.0;
   double tp = 0.0;
   bool sent = false;

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(SlippagePoints);
   trade.SetTypeFillingBySymbol(symbol);

   if(buySignal)
   {
      sl = NormalizeDouble(tick.ask - stopDistance, digits);
      tp = NormalizeDouble(
         tick.ask + stopDistance * RewardRiskRatio, digits);

      sent = trade.Buy(
         volume, symbol, 0.0, sl, tp, "Lee AutoTrader BUY");
   }
   else if(sellSignal)
   {
      sl = NormalizeDouble(tick.bid + stopDistance, digits);
      tp = NormalizeDouble(
         tick.bid - stopDistance * RewardRiskRatio, digits);

      sent = trade.Sell(
         volume, symbol, 0.0, sl, tp, "Lee AutoTrader SELL");
   }

   if(sent)
   {
      Print("Lee AutoTrader: order request accepted for ", symbol,
            ". Volume=", DoubleToString(volume, 2),
            ". Check broker execution result.");
   }
   else
   {
      Print("Lee AutoTrader: order failed for ", symbol,
            ". Retcode=", trade.ResultRetcode(),
            " ", trade.ResultRetcodeDescription());
   }
}

//========================= INITIALIZATION ============================

int OnInit()
{
   // Safety: this version refuses to operate on a real trading account.
   ENUM_ACCOUNT_TRADE_MODE accountMode =
      (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);

   if(accountMode != ACCOUNT_TRADE_MODE_DEMO)
   {
      Print("Lee AutoTrader safety stop: demo account required.");
      return INIT_FAILED;
   }

   if(RiskPercent <= 0.0 || RiskPercent > 1.0)
   {
      Print("RiskPercent must be above 0 and no more than 1%.");
      return INIT_PARAMETERS_INCORRECT;
   }

   if(DailyLossLimitPct <= 0.0 ||
      MaxOpenPositions < 1 ||
      FastEMA <= 0 ||
      SlowEMA <= FastEMA ||
      RSIPeriod <= 0 ||
      ATRPeriod <= 0 ||
      ATR_StopMultiplier <= 0.0 ||
      RewardRiskRatio <= 0.0)
   {
      Print("Lee AutoTrader: invalid input settings.");
      return INIT_PARAMETERS_INCORRECT;
   }

   string rawSymbols[];
   ushort separator = StringGetCharacter(",", 0);

   int total = StringSplit(TradingSymbols, separator, rawSymbols);

   if(total <= 0)
   {
      Print("Lee AutoTrader: no symbols were supplied.");
      return INIT_FAILED;
   }

   ArrayResize(Symbols, total);

   for(int i = 0; i < total; i++)
   {
      string symbol = CleanSymbol(rawSymbols[i]);

      if(symbol == "")
         continue;

      if(!SymbolSelect(symbol, true))
      {
         Print("Lee AutoTrader: cannot select symbol ", symbol,
               ". Check the broker's exact symbol name.");
         continue;
      }

      int fastHandle = iMA(
         symbol, SignalTimeframe, FastEMA, 0, MODE_EMA, PRICE_CLOSE);

      int slowHandle = iMA(
         symbol, SignalTimeframe, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);

      int rsiHandle = iRSI(
         symbol, SignalTimeframe, RSIPeriod, PRICE_CLOSE);

      int atrHandle = iATR(
         symbol, SignalTimeframe, ATRPeriod);

      if(fastHandle == INVALID_HANDLE ||
         slowHandle == INVALID_HANDLE ||
         rsiHandle == INVALID_HANDLE ||
         atrHandle == INVALID_HANDLE)
      {
         Print("Lee AutoTrader: indicator setup failed for ", symbol);

         if(fastHandle != INVALID_HANDLE)
            IndicatorRelease(fastHandle);

         if(slowHandle != INVALID_HANDLE)
            IndicatorRelease(slowHandle);

         if(rsiHandle != INVALID_HANDLE)
            IndicatorRelease(rsiHandle);

         if(atrHandle != INVALID_HANDLE)
            IndicatorRelease(atrHandle);

         continue;
      }

      int n = SymbolCount;

      ArrayResize(Symbols, n + 1);
      ArrayResize(LastBarTime, n + 1);
      ArrayResize(FastEMAHandles, n + 1);
      ArrayResize(SlowEMAHandles, n + 1);
      ArrayResize(RSIHandles, n + 1);
      ArrayResize(ATRHandles, n + 1);

      Symbols[n] = symbol;
      LastBarTime[n] = 0;
      FastEMAHandles[n] = fastHandle;
      SlowEMAHandles[n] = slowHandle;
      RSIHandles[n] = rsiHandle;
      ATRHandles[n] = atrHandle;

      SymbolCount++;
   }

   if(SymbolCount == 0)
   {
      Print("Lee AutoTrader: no usable symbols. Check Market Watch.");
      return INIT_FAILED;
   }

   UpdateDailyRisk();

   EventSetTimer(10);

   Print("Lee Forex AutoTrader initialized on DEMO.");
   Print("Loaded symbols: ", SymbolCount);
   Print("Risk per trade: ", RiskPercent, "%");
   Print("Daily loss threshold: ", DailyLossLimitPct, "%");
   Print("Maximum EA positions: ", MaxOpenPositions);

   return INIT_SUCCEEDED;
}

//========================= MAIN LOOP ================================

void OnTick()
{
   UpdateDailyRisk();

   for(int i = 0; i < SymbolCount; i++)
   {
      if(IsNewBar(i))
         CheckSymbol(i);
   }
}

// Timer allows the EA to check symbols even when the chart symbol
// itself has limited tick activity.
void OnTimer()
{
   UpdateDailyRisk();

   for(int i = 0; i < SymbolCount; i++)
   {
      if(IsNewBar(i))
         CheckSymbol(i);
   }
}

//========================= CLEANUP ==================================

void OnDeinit(const int reason)
{
   EventKillTimer();

   for(int i = 0; i < SymbolCount; i++)
   {
      if(FastEMAHandles[i] != INVALID_HANDLE)
         IndicatorRelease(FastEMAHandles[i]);

      if(SlowEMAHandles[i] != INVALID_HANDLE)
         IndicatorRelease(SlowEMAHandles[i]);

      if(RSIHandles[i] != INVALID_HANDLE)
         IndicatorRelease(RSIHandles[i]);

      if(ATRHandles[i] != INVALID_HANDLE)
         IndicatorRelease(ATRHandles[i]);
   }

   Print("Lee Forex AutoTrader stopped.");
}
//+------------------------------------------------------------------+
