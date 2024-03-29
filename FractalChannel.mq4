#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1  clrLightPink
#property indicator_color2  clrLightBlue
#property indicator_color3  clrCoral
#property indicator_color4  clrCornflowerBlue
#property indicator_color5  clrTurquoise
#property indicator_color6  clrTomato
#property indicator_color7  clrOrange
#property indicator_color8  clrOliveDrab
#property indicator_color9  clrMediumSeaGreen
#property indicator_color10 clrDeepPink

#property indicator_width1  0
#property indicator_width2  0
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  2
#property indicator_width6  2
#property indicator_style7  2
#property indicator_style8  2
#property indicator_width9  1
#property indicator_width10 1


enum ENUM_PRICE
{
   close,               // Close
   open,                // Open
   high,                // High
   low,                 // Low
   median,              // Median
   typical,             // Typical
   weightedClose,       // Weighted Close
   haClose,             // Heiken Ashi Close
   haOpen,              // Heiken Ashi Open
   haHigh,              // Heiken Ashi High   
   haLow,               // Heiken Ashi Low
   haMedian,            // Heiken Ashi Median
   haTypical,           // Heiken Ashi Typical
   haWeighted           // Heiken Ashi Weighted Close
};

enum ENUM_BREAK
{
   byclose,             // by Close
   byuplo               // by Up/Lo Band Price
};

enum ENUM_RETRACE
{
   channel,             // Price Channel
   pctprice,            // % of Price
   pips,                // Price Change in pips
   ratr                 // ATR Multiplier
};

enum ENUM_ZZCHANNEL
{
   zzoff,               // Off
   hilo,                // High/Low Channel
   chaos                // Chaos Bands
};

enum ENUM_TRENDCHANNEL
{
   trendoff,            // Off
   classic,             // Classic method
   bollinger,           // Bollinger's method
   both                 // Both methods
};


//---- input parameters
input ENUM_TIMEFRAMES   TimeFrame            =        0;       // Timeframe
input ENUM_PRICE        UpBandPrice          =        2;       // Upper Band Price
input ENUM_PRICE        LoBandPrice          =        3;       // Lower Band Price 
input ENUM_BREAK        BreakOutMode         =        0;       // Breakout Mode
input double            ReversalValue        =       12;       // Reversal Value according to Retrace Method
input ENUM_RETRACE      RetraceMethod        =        0;       // Retrace Method
input int               ATRperiod            =       50;       // ATR period (RetraceMethod=3)
input bool              ShowZigZag           =    false;       // Show ZigZag
input bool              ShowSignals          =    false;       // Show Signals 
input bool              ShowPriceChannel     =    false;       // ShowPriceChannel 
input ENUM_ZZCHANNEL    ZigZagChannelMode    =        2;       // ZigZag Channel Mode 

input string            pattern123           = "==== 1-2-3 Pattern: ====";    
input bool              Show123Pattern       =    false; 
input color             BullishColor         = clrAquamarine; 
input color             BearishColor         = clrLightCoral; 
input int               FontSize             =        8;        
input int               LineWidth            =        4;

input string            trendChannel         = "==== Trend Channel: ====";  
input ENUM_TRENDCHANNEL TrendChannelMode     =        1;       // Trend Channel Mode
input int               PivotFromRight       =        0;       // Number of the 1st pivot from the right(0-current pivot)  
input int               PivotsFromLeft       =        5;       // Pivots to the 2nd pivot from left side 
input color             UpTrendChannelColor  = clrDeepSkyBlue;  
input color             DnTrendChannelColor  = clrTomato;
input string            UniqueName           =  "unizz"; 

input string            alerts               = "==== Alerts & Emails: ====";
input bool              AlertOn              =    false;       //
input int               AlertShift           =        1;       // Alert Shift:0-current bar,1-previous bar
input int               SoundsNumber         =        5;       // Number of sounds after Signal
input int               SoundsPause          =        5;       // Pause in sec between sounds 
input string            UpTrendSound         = "alert.wav";
input string            DnTrendSound         = "alert2.wav";
input bool              EmailOn              =    false;       // 
input int               EmailsNumber         =        1;       //
input bool              PushNotificationOn   =    false;



double upZZ1[];
double dnZZ1[];  
double hiBuffer[];
double loBuffer[];
double upSignal[];
double dnSignal[];
double hiband[];
double loband[];
double upPattern[];
double dnPattern[];
double upPrice[];
double loPrice[];
double trend[];
double zzlength[];
double trendslope[];



int      timeframe, cBars, leftpivots;  
double   period, _point;
string   short_name, TF, IndicatorName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   timeframe = TimeFrame;
   if(timeframe <= Period()) timeframe = Period(); 
   TF = tf(timeframe);
   
   IndicatorDigits(Digits);
   
   IndicatorName = WindowExpertName();
     
   period = ReversalValue;
   
   
   IndicatorBuffers(15);   
   SetIndexBuffer( 0,     upZZ1); SetIndexStyle( 0,DRAW_ZIGZAG);
   SetIndexBuffer( 1,     dnZZ1); SetIndexStyle( 1,DRAW_ZIGZAG);
   SetIndexBuffer( 2,  hiBuffer); SetIndexStyle( 2,  DRAW_LINE); 
   SetIndexBuffer( 3,  loBuffer); SetIndexStyle( 3,  DRAW_LINE); 
   SetIndexBuffer( 4,  upSignal); SetIndexStyle( 4, DRAW_ARROW); SetIndexArrow( 4,159);
   SetIndexBuffer( 5,  dnSignal); SetIndexStyle( 5, DRAW_ARROW); SetIndexArrow( 5,159);
   SetIndexBuffer( 6,    hiband); if(ShowPriceChannel) SetIndexStyle(6,DRAW_LINE); else SetIndexStyle(6,DRAW_NONE); 
   SetIndexBuffer( 7,    loband); if(ShowPriceChannel) SetIndexStyle(7,DRAW_LINE); else SetIndexStyle(7,DRAW_NONE);   
   SetIndexBuffer( 8, upPattern); SetIndexStyle( 8, DRAW_ARROW); SetIndexArrow( 8,233);
   SetIndexBuffer( 9, dnPattern); SetIndexStyle( 9, DRAW_ARROW); SetIndexArrow( 9,234);
   SetIndexBuffer(10,   upPrice);   
   SetIndexBuffer(11,   loPrice);
   SetIndexBuffer(12,     trend);
   SetIndexBuffer(13,  zzlength);
   SetIndexBuffer(14,trendslope);
   
   short_name = IndicatorName+"["+TF+"]("+UpBandPrice+","+LoBandPrice+","+DoubleToStr(ReversalValue,1)+","+RetraceMethod+")";
   IndicatorShortName(short_name);
   
   SetIndexLabel( 0,"Upper ZigZag"); SetIndexEmptyValue(0,0.0);
   SetIndexLabel( 1,"Lower ZigZag"); SetIndexEmptyValue(1,0.0);   
   SetIndexLabel( 2,"UniZigZag Upper Band"); 
   SetIndexLabel( 3,"UniZigZag Lower Band");
   SetIndexLabel( 4,"UpSignal"); 
   SetIndexLabel( 5,"DnSignal");
   SetIndexLabel( 6,"Channel\'s Upper Band"); 
   SetIndexLabel( 7,"Channel\'s Lower Band");
   SetIndexLabel( 8,"123Pattern UpSignal"); 
   SetIndexLabel( 9,"123Pattern DnSignal");    
//---- 
   cBars = iBars(NULL,timeframe)*timeframe/Period() - MathMax(ReversalValue,ATRperiod);
   int draw_begin = Bars - cBars;
   SetIndexDrawBegin( 0,draw_begin);
   SetIndexDrawBegin( 1,draw_begin);
   SetIndexDrawBegin( 2,draw_begin);
   SetIndexDrawBegin( 3,draw_begin);
   SetIndexDrawBegin( 4,draw_begin);
   SetIndexDrawBegin( 5,draw_begin);
   SetIndexDrawBegin( 6,draw_begin);
   SetIndexDrawBegin( 7,draw_begin);
   SetIndexDrawBegin( 8,draw_begin);
   SetIndexDrawBegin( 9,draw_begin);
   
   
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
   SetIndexEmptyValue(4,0);
   SetIndexEmptyValue(5,0);
   SetIndexEmptyValue(6,0);
   SetIndexEmptyValue(7,0);
   SetIndexEmptyValue(8,0);
   SetIndexEmptyValue(9,0);
 
   
   _point = _Point*MathPow(10,Digits%2);
   
   leftpivots = MathMax(2 + PivotsFromLeft,2);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
   if(LineWidth >= 0) {ObjectsDeleteAll(0,UniqueName); ChartRedraw();}
}
//+------------------------------------------------------------------+
//|                 |
//+------------------------------------------------------------------+
int start()
{
   int i,shift, counted_bars = IndicatorCounted(),limit;
   
   if (counted_bars > 0) limit = Bars - counted_bars - 1;     
   if (counted_bars < 1) 
   {
   limit = Bars - 1;    
      for(i=0;i<limit;i++)
      { 
      upZZ1[i]     = 0;
      dnZZ1[i]     = 0;
      hiBuffer[i]  = 0;
      loBuffer[i]  = 0;
      upSignal[i]  = 0;
      dnSignal[i]  = 0;
      hiband[i]    = 0;
      loband[i]    = 0;
      upPattern[i] = 0;
      dnPattern[i] = 0;
      }
   SetIndexDrawBegin(0,period);
   legs[0] = 0;
   }
   	
   
   for(shift=limit;shift>=0;shift--) 
   {	  
      if(UpBandPrice <= 6) upPrice[shift] = iMA(NULL,0,1,0,0,(int)UpBandPrice,shift);   
      else
      if(UpBandPrice > 6 && UpBandPrice <= 13) upPrice[shift] = HeikenAshi(0,UpBandPrice-7,shift);
      
      if(LoBandPrice <= 6) loPrice[shift] = iMA(NULL,0,1,0,0,(int)LoBandPrice,shift);   
      else
      if(LoBandPrice > 6 && LoBandPrice <= 13) loPrice[shift] = HeikenAshi(1,LoBandPrice-7,shift);    
   }   
    
   
   
   
   if(timeframe != Period())
	{
   int pivotshift = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                            ShowZigZag,ShowSignals,false,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                            "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                            "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,6,0);      
    
   limit = MathMax(limit,MathMax(pivotshift+1,1)*timeframe/Period());   
   
   
      for(shift=0;shift<limit;shift++) 
      {	
      int y = iBarShift(NULL,timeframe,Time[shift]);
      
      double upzz = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                            ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                            "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                            "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,0,y);   
      
      double dnzz = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                            ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                            "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                            "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,1,y);   
      
      datetime time = iTime(NULL,TimeFrame,y);
      upZZ1[shift] = 0;
      dnZZ1[shift] = 0;   
    
         if(time == Time[shift])
         {
         int mtfshift = iBarShift(NULL,0,time);    
         
            if(upzz > 0)
            {
            datetime uptime = time; 
                      
            if(y > 0) int uplen = mtfshift - iBarShift(NULL,0,iTime(NULL,TimeFrame,y-1)) + 1; else uplen = mtfshift + 1;
                        
            int    upshift  = 0;
            double maxvalue = 0;   
            
               for(i=0;i<uplen;i++)
               { 
               double upvalue = upPrice[shift-i];   
               if(upvalue > maxvalue) {maxvalue = upvalue; upshift = i;}
               }
   
            upZZ1[mtfshift-upshift] = upzz; 
            }
      
            if(dnzz > 0)
            {
            datetime dntime = time; 
                      
            if(y > 0) int dnlen = mtfshift - iBarShift(NULL,0,iTime(NULL,TimeFrame,y-1)) + 1; else dnlen = mtfshift + 1;
           
            int    dnshift  = 0;
            double minvalue = 10000000;   
            
               for(i=0;i<dnlen;i++)
               { 
               double dnvalue = loPrice[shift-i];   
               if(dnvalue < minvalue) {minvalue = dnvalue; dnshift = i;}
               }
      
            dnZZ1[mtfshift-dnshift] = dnzz; 
            }
         }
      
      hiBuffer[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,2,y);   
      
      loBuffer[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,3,y);        
      
      hiband[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,6,y);       
      
      loband[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,7,y);         
         
         if(ShowSignals)
         {
         upSignal[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                   ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                   "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                   "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,4,y);         
         
         dnSignal[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                   ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                   "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                   "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,5,y);         
         }
         
         
         if(Show123Pattern)
         {
         upPattern[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                    ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                    "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                    "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,8,y); 
         dnPattern[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,BreakOutMode,ReversalValue,RetraceMethod,ATRperiod,
                                    ShowZigZag,ShowSignals,ShowPriceChannel,ZigZagChannelMode,"",Show123Pattern,BullishColor,BearishColor,FontSize,LineWidth,
                                    "",TrendChannelMode,PivotFromRight,PivotsFromLeft,UpTrendChannelColor,DnTrendChannelColor,UniqueName,
                                    "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,9,y); 
         
            if(LineWidth >= 0)
            {
               if(upPattern[shift] > 0)
               {
               string upname = UniqueName+" up "+TimeToString(Time[shift]);   
               moveLine(upname+" line0",-1,timeframe/Period());   
               moveLine(upname+" line1", 1,timeframe/Period());      
               }
            
               if(dnPattern[shift] > 0)
               {
               string dnname = UniqueName+" dn "+TimeToString(Time[shift]);   
               moveLine(dnname+" line0", 1,timeframe/Period());   
               moveLine(dnname+" line1",-1,timeframe/Period());      
               }
            }
         }
      }
   return(0);
   }
   
   if(period > 0) _uniZigZag(upZZ1,dnZZ1,period,limit,counted_bars);
        
   
   
   return(0);   
}


int      nlow, nhigh, legs[2], prevswing;
double   upBand[2], loBand[2], hiValue[2], loValue[2], hh[2], ll[2], swings[], zzarray[3]; 
datetime zztime[3], prevzztime, hiTime[2], loTime[2], swingtime[], prevtime;

void _uniZigZag(double& upZZ[],double& dnZZ[],double retrace,int limit,int counted_bars)
{
   int i;
  
     
   for(int shift=limit;shift>=0;shift--) 
   {	
      if(prevtime != Time[shift])
      {
      hiTime[1]  = hiTime[0];
      loTime[1]  = loTime[0];
      upBand[1]  = upBand[0];
      loBand[1]  = loBand[0];
      hiValue[1] = hiValue[0];
      loValue[1] = loValue[0];
      hh[1]      = hh[0];
      ll[1]      = ll[0];
      legs[1]    = legs[0];
      prevtime   = Time[shift];
      }
               
      if(shift < Bars - retrace)
      {
      hiTime[0]  = hiTime[1];
      loTime[0]  = loTime[1];
      upBand[0]  = upBand[1];
      loBand[0]  = loBand[1];   
      hh[0]      = hh[1];
      ll[0]      = ll[1];
      legs[0]    = legs[1];
      
      
      hiValue[0] = 0;
      loValue[0] = 0;   
      
      trend[shift] = trend[shift+1];
    
         
         switch(RetraceMethod)
         {
         case 0: upBand[0] = upPrice[HighestBar(retrace,shift,0)]; 
                 loBand[0] = loPrice[ LowestBar(retrace,shift,0)];  
                 break;
         
         case 1: if(upPrice[shift] > upBand[0])   
                 {
                 upBand[0] = upPrice[shift];
                 loBand[0] = upBand[0]*(1 - 0.01*retrace); 
                 }
                 
                 if(loPrice[shift] < loBand[0])  
                 {
                 loBand[0] = loPrice[shift];
                 upBand[0] = loBand[0]*(1 + 0.01*retrace); 
                 }
                 break;
         
         case 2: if(upPrice[shift] >= upBand[0])   
                 {
                 upBand[0] = upPrice[shift];
                 loBand[0] = upBand[0] - retrace*_point; 
                 }
                 
                 if(loPrice[shift] <= loBand[0])  
                 {
                 loBand[0] = loPrice[shift];
                 upBand[0] = loBand[0] + retrace*_point; 
                 }
                 break;
                     
         case 3: double atr = iATR(NULL,0,ATRperiod,shift);
                 
                 if(upPrice[shift] >= upBand[0])   
                 {
                 upBand[0] = upPrice[shift];
                 loBand[0] = upBand[0] - retrace*atr; 
                 }
                 
                 if(loPrice[shift] <= loBand[0])  
                 {
                 loBand[0] = loPrice[shift];
                 upBand[0] = loBand[0] + retrace*atr; 
                 }
                 break;        
         }
         
         upSignal[shift] = 0;
         dnSignal[shift] = 0;
         
         if(ShowPriceChannel)
         {  
         hiband[shift] = upBand[0];
         loband[shift] = loBand[0];
         }
         
         bool upbreak = false, dnbreak = false;
         
         switch(BreakOutMode)
         {
         case 1:  if(upPrice[shift] > upBand[1] && trend[shift] <= 0) upbreak = true;  
                  if(loPrice[shift] < loBand[1] && trend[shift] >= 0) dnbreak = true;
                  break;    
         
         default: if(Close[shift] > upBand[1] && trend[shift] <= 0) upbreak = true;    
                  if(Close[shift] < loBand[1] && trend[shift] >= 0) dnbreak = true;
                  break; 
         }
         
         
         if(upbreak && (loPrice[shift] >= loBand[1] ||(loPrice[shift] < loBand[1] && Close[shift] > Close[shift+1])) && upBand[1] > 0) 
         {
         trend[shift] = 1; 
          
         int lobar = LowestBar(iBarShift(NULL,0,hiTime[0],FALSE) - shift,shift,1);
      
         loValue[0] = loPrice[lobar];
         loTime[0]  = Time[lobar];
         hh[0]      = upPrice[shift];
         if(ShowSignals) upSignal[shift] = loValue[0];
         if(ShowZigZag ) dnZZ[lobar]     = loValue[0];
         
         ArrayResize(swings   ,legs[0]+1); 
         ArrayResize(swingtime,legs[0]+1);
         
         swings[legs[0]]    = dnZZ[lobar]; 
         swingtime[legs[0]] = Time[lobar]; 
         legs[0] += 1; 
         }   
                 
         if(dnbreak && (upPrice[shift] <= upBand[1] ||(upPrice[shift] > upBand[1] && Close[shift] < Close[shift+1])) && loBand[1] > 0) 
         {
         trend[shift] =-1; 
         
         int hibar = HighestBar(iBarShift(NULL,0,loTime[0],FALSE)-shift,shift,1);
         
         hiValue[0] = upPrice[hibar];
         hiTime[0]  = Time[hibar];
         ll[0]      = loPrice[shift];
         if(ShowSignals) dnSignal[shift] = hiValue[0];
         if(ShowZigZag ) upZZ[hibar]     = hiValue[0]; 
         
         ArrayResize(swings   ,legs[0]+1); 
         ArrayResize(swingtime,legs[0]+1);
         
         swings[legs[0]]    = upZZ[hibar]; 
         swingtime[legs[0]] = Time[hibar]; 
         legs[0] += 1; 
         }
         
        
         
         
         if(shift == 0)
         { 
         upZZ[shift] = 0;
         dnZZ[shift] = 0;  
         
            
            if(trend[shift] > 0) 
            {
            if(trend[shift+1] > 0 && dnZZ[nlow] > 0) dnZZ[nlow] = 0;
            int hilen = iBarShift(NULL,0,loTime[0],FALSE);
            nhigh = HighestBar(hilen,0,1);
            for(i=hilen;i>=0;i--) upZZ[i] = 0; 
            
            if(ShowZigZag       ) upZZ[nhigh]   = upPrice[nhigh];
            if(!ShowPriceChannel) hiband[shift] = hilen;
            
            ArrayResize(swings   ,legs[0]+1); 
            ArrayResize(swingtime,legs[0]+1);
         
            swings[legs[0]]    = upZZ[nhigh]; 
            swingtime[legs[0]] = Time[nhigh]; 
            }   
         
            if(trend[shift] < 0)
            { 
            if(trend[shift+1] < 0 && upZZ[nhigh] > 0) upZZ[nhigh] = 0;
            int lolen = iBarShift(NULL,0,hiTime[0],FALSE);
            nlow = LowestBar(lolen,0,1);
            for(i=lolen;i>=0;i--) dnZZ[i] = 0; 
            
            if(ShowZigZag       ) dnZZ[nlow]    = loPrice[nlow];
            if(!ShowPriceChannel) hiband[shift] = lolen;
            
            ArrayResize(swings   ,legs[0]+1); 
            ArrayResize(swingtime,legs[0]+1);
         
            swings[legs[0]]    = dnZZ[nlow]; 
            swingtime[legs[0]] = Time[nlow]; 
            }
         }
      
         if(ZigZagChannelMode > 0)
         { 
         hiBuffer[shift] = hiBuffer[shift+1];
         loBuffer[shift] = loBuffer[shift+1];
       
         if(hiValue[0] > 0) hiBuffer[shift] = hiValue[0];
         if(ZigZagChannelMode == 1) if(upPrice[shift] > hiBuffer[shift]) hiBuffer[shift] = upPrice[shift]; 
       
         if(loValue[0] > 0) loBuffer[shift] = loValue[0];    
         if(ZigZagChannelMode == 1) if(loPrice[shift] < loBuffer[shift]) loBuffer[shift] = loPrice[shift]; 
         }
         
         
         if(Show123Pattern && shift < cBars)
         {
         bool upzzbreak = false;     
         bool dnzzbreak = false;
         
            
            switch(BreakOutMode)
            {
            case 1:  if(upPrice[shift] > hiBuffer[shift] && upPrice[shift+1] <= hiBuffer[shift+1]) upzzbreak = true;  
                     if(loPrice[shift] < loBuffer[shift] && loPrice[shift+1] >= loBuffer[shift+1]) dnzzbreak = true;
                     break;    
         
            default: if(Close[shift] > hiBuffer[shift] && Close[shift+1] <= hiBuffer[shift+1]) upzzbreak = true;
                     if(Close[shift] < loBuffer[shift] && Close[shift+1] >= loBuffer[shift+1]) dnzzbreak = true;
                     break; 
            }   
         
         
         int    last     = legs[0] - 1;    
         double range    = iATR(NULL,0,10,shift+1);
         double height01 = MathAbs(swings[last-1] - swings[last]);
         double height12 = MathAbs(swings[last-1] - swings[last-2]);
         
         upPattern[shift] = 0;
         dnPattern[shift] = 0;
       
          
            if((upzzbreak || dnzzbreak) && height01 < height12 && swingtime[last] != prevzztime)  
            {
               if(upzzbreak && swings[last] < swings[last-1] && swings[last-1] > swings[last-2]) 
               {
               upPattern[shift] = Low[shift] - range; 
                  
                  if(LineWidth >= 0) 
                  {
                  string upname = UniqueName+" up "+TimeToString(Time[shift]);
            
                     if(ObjectFind(0,upname+" line0") >= 0)
                     {
                     ObjectDelete(0,upname+" line0"); 
                     ObjectDelete(0,upname+" line1");
                     ObjectDelete(0,upname+" #1"); 
                     ObjectDelete(0,upname+" #2"); 
                     ObjectDelete(0,upname+" #3");   
                     }
                  
                  plot123Pattern(upname,1,swingtime[last],swings[last],swingtime[last-1],swings[last-1],swingtime[last-2],swings[last-2],BullishColor,LineWidth,0.5*range,FontSize);
                  }
               }
               
               if(dnzzbreak && swings[last] > swings[last-1] && swings[last-1] < swings[last-2]) 
               {
               dnPattern[shift] = High[shift] + range;
               
                  if(LineWidth >= 0)
                  {   
                  string dnname = UniqueName+" dn "+TimeToString(Time[shift]);   
            
                     if(ObjectFind(0,dnname+" line0") >= 0)
                     {
                     ObjectDelete(0,dnname+" line0"); 
                     ObjectDelete(0,dnname+" line1");
                     ObjectDelete(0,dnname+" #1"); 
                     ObjectDelete(0,dnname+" #2"); 
                     ObjectDelete(0,dnname+" #3");   
                     }   
                  
                  plot123Pattern(dnname,-1,swingtime[last],swings[last],swingtime[last-1],swings[last-1],swingtime[last-2],swings[last-2],BearishColor,LineWidth,0.5*range,FontSize);
                  }   
               }
            }     
         
         if(upPattern[shift+1] > 0) prevzztime = swingtime[last];
         if(dnPattern[shift+1] > 0) prevzztime = swingtime[last];   
         }
      }      
   }

   if(TrendChannelMode > 0)
   {
   int lastswing = legs[0] - PivotFromRight;    
   int direction = -2;
       
      if(lastswing != prevswing)
      { 
      int  cnt = 0, firstpivot;   
      bool trendfound = false, upcondition, dncondition;   
         
         while(!trendfound && cnt < lastswing)
         {
            switch(TrendChannelMode)
            {
            case 1:  upcondition = swings[lastswing-cnt] > swings[lastswing-2-cnt] && swings[lastswing-cnt] < swings[lastswing-1-cnt] && swings[lastswing-1-cnt] > swings[lastswing-2-cnt];
                     dncondition = swings[lastswing-cnt] < swings[lastswing-2-cnt] && swings[lastswing-cnt] > swings[lastswing-1-cnt] && swings[lastswing-1-cnt] < swings[lastswing-2-cnt];  
                     break;
            
            case 2:  upcondition = swings[lastswing-cnt] > swings[lastswing-2-cnt] && swings[lastswing-cnt] > swings[lastswing-1-cnt] && swings[lastswing-1-cnt] < swings[lastswing-2-cnt];
                     dncondition = swings[lastswing-cnt] < swings[lastswing-2-cnt] && swings[lastswing-cnt] < swings[lastswing-1-cnt] && swings[lastswing-1-cnt] > swings[lastswing-2-cnt];  
                     break;
                     
            case 3:  upcondition = swings[lastswing-cnt] > swings[lastswing-2-cnt] && ((swings[lastswing-cnt] < swings[lastswing-1-cnt] && swings[lastswing-1-cnt] > swings[lastswing-2-cnt])
                                                                            ||(swings[lastswing-cnt] > swings[lastswing-1-cnt] && swings[lastswing-1-cnt] < swings[lastswing-2-cnt]));
                     dncondition = swings[lastswing-cnt] < swings[lastswing-2-cnt] && ((swings[lastswing-cnt] > swings[lastswing-1-cnt] && swings[lastswing-1-cnt] < swings[lastswing-2-cnt])
                                                                            ||(swings[lastswing-cnt] < swings[lastswing-1-cnt] && swings[lastswing-1-cnt] > swings[lastswing-2-cnt]));  
                     break;
            }
            
            if(upcondition)
            {
            trendfound = true; 
            direction  = 1;
            firstpivot = lastswing - cnt;         
            }
            else
            if(dncondition)
            {
            trendfound = true; 
            direction  =-1;
            firstpivot = lastswing - cnt;   
            }
            else
            if(swings[lastswing-cnt] == swings[lastswing-2-cnt])// && (Swings[lastswing-cnt] < Swings[lastswing-1-cnt] || Swings[lastswing-cnt] > Swings[lastswing-1-cnt]))
            {
            trendfound = true; 
            direction  = 0;
            firstpivot = lastswing - cnt;         
            }
                  
         cnt++;
         }  
      }
   
      if(trendfound)
      {
      ObjectDelete(0,UniqueName+" trendline#1");
      ObjectDelete(0,UniqueName+" trendline#2");
      ObjectDelete(0,UniqueName+" trendmiddle");
      
      trendslope[0] = (swings[firstpivot] - swings[firstpivot-2])/(iBarShift(NULL,0,swingtime[firstpivot-2]) - iBarShift(NULL,0,swingtime[firstpivot])); ;
      
      double line1   = swings[firstpivot  ]+ trendslope[0]*(iBarShift(NULL,0,swingtime[firstpivot  ]) - iBarShift(NULL,0,swingtime[firstpivot-leftpivots])); 
      double line2   = swings[firstpivot-1]+ trendslope[0]*(iBarShift(NULL,0,swingtime[firstpivot-1]) - iBarShift(NULL,0,swingtime[firstpivot-leftpivots])); 
      double middle1 = 0.5*(line1 + line2);
      double middle2 = middle1             - trendslope[0]*(iBarShift(NULL,0,swingtime[firstpivot-1]) - iBarShift(NULL,0,swingtime[firstpivot-leftpivots]));
                 
      ObjectCreate(0,UniqueName+" trendline#1",OBJ_TREND,0,swingtime[firstpivot-leftpivots],line1  ,swingtime[firstpivot]  ,swings[firstpivot  ]);
      ObjectCreate(0,UniqueName+" trendline#2",OBJ_TREND,0,swingtime[firstpivot-leftpivots],line2  ,swingtime[firstpivot-1],swings[firstpivot-1]);
      ObjectCreate(0,UniqueName+" trendmiddle",OBJ_TREND,0,swingtime[firstpivot-leftpivots],middle1,swingtime[firstpivot-1],middle2);
     
      
      if(direction >  0) color ChannelColor = UpTrendChannelColor; 
      if(direction <  0) ChannelColor = DnTrendChannelColor;
      if(direction == 0) ChannelColor = clrLightGray;
      
      ObjectSetInteger(0,UniqueName+" trendline#1",OBJPROP_COLOR,ChannelColor);
      ObjectSetInteger(0,UniqueName+" trendline#1",OBJPROP_RAY,true);
      ObjectSetInteger(0,UniqueName+" trendline#1",OBJPROP_WIDTH,1);
      ObjectSetInteger(0,UniqueName+" trendline#1",OBJPROP_STYLE,STYLE_SOLID);     
      
      ObjectSetInteger(0,UniqueName+" trendline#2",OBJPROP_COLOR,ChannelColor);
      ObjectSetInteger(0,UniqueName+" trendline#2",OBJPROP_RAY,true);
      ObjectSetInteger(0,UniqueName+" trendline#2",OBJPROP_WIDTH,1);
      ObjectSetInteger(0,UniqueName+" trendline#2",OBJPROP_STYLE,STYLE_SOLID);     
      
      ObjectSetInteger(0,UniqueName+" trendmiddle",OBJPROP_COLOR,ChannelColor);
      ObjectSetInteger(0,UniqueName+" trendmiddle",OBJPROP_RAY,true);
      ObjectSetInteger(0,UniqueName+" trendmiddle",OBJPROP_STYLE,STYLE_DASHDOT);     
      } 
   }  
   


   if(AlertOn || EmailOn || PushNotificationOn)
   {
   bool uptrend = trend[AlertShift] > 0 && trend[AlertShift+1] <= 0;                  
   bool dntrend = trend[AlertShift] < 0 && trend[AlertShift+1] >= 0;
   
      if(Show123Pattern)
      {
      bool uppattern = upPattern[AlertShift] > 0 && upPattern[AlertShift] != EMPTY_VALUE && upPattern[AlertShift+1] == EMPTY_VALUE; 
      bool dnpattern = dnPattern[AlertShift] > 0 && dnPattern[AlertShift] != EMPTY_VALUE && dnPattern[AlertShift+1] == EMPTY_VALUE; 
      }
         
      if(uptrend || dntrend || uppattern || dnpattern)
      {
         if(isNewBar(timeframe))
         {
            if(AlertOn)
            {
            BoxAlert(uptrend," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
            BoxAlert(dntrend," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
               if(Show123Pattern)
               {
               BoxAlert(uppattern," : 123 Pattern BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
               BoxAlert(dnpattern," : 123 Pattern SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
               }
            }
                   
            if(EmailOn)
            {
            EmailAlert(uptrend,"BUY" ," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            EmailAlert(dntrend,"SELL"," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
               if(Show123Pattern)
               {
               EmailAlert(uppattern,"123 Pattern BUY" ," : 123 Pattern BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits),EmailsNumber);   
               EmailAlert(dnpattern,"123 Pattern SELL"," : 123 Pattern SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
               }   
            }
         
            if(PushNotificationOn)
            {
            PushAlert(uptrend," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
            PushAlert(dntrend," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
               if(Show123Pattern)
               {
               PushAlert(uppattern," : 123 Pattern BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
               PushAlert(dnpattern," : 123 Pattern SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
               }
            }
         }
         else
         {
            if(AlertOn)
            {
            WarningSound(uptrend,SoundsNumber,SoundsPause,UpTrendSound,Time[AlertShift]);
            WarningSound(dntrend,SoundsNumber,SoundsPause,DnTrendSound,Time[AlertShift]);
               if(Show123Pattern)
               {
               WarningSound(uppattern,SoundsNumber,SoundsPause,UpTrendSound,Time[AlertShift]);  
               WarningSound(dnpattern,SoundsNumber,SoundsPause,UpTrendSound,Time[AlertShift]);
               }  
            }
         }   
      }
   }   
}



//-------------------------------------------  

int LowestBar(int len,int k,int opt)
{
   double min = 10000000;   
   
   if(len <= 0) int lobar = k;
   else   
   for(int i=k+len-1;i>=k;i--)
   {
   double lo0 = loPrice[i];
   if(opt == 1) double lo1 = loPrice[i-1];
   if((opt == 1 && (i==0 || (i > 0/*&& lo0 < lo1*/)) && lo0 <= min) || (opt==0 && lo0 <= min)) {min = lo0; lobar = i;}
   }   
   
   return(lobar);
} 

//-------------------------------------------  

int HighestBar(int len,int k,int opt)
{
   double max = -10000000;   
   
   if(len <= 0) int hibar = k;
   else
   for (int i=k+len-1;i>=k;i--)
   {
   double hi0 = upPrice[i];
   if(opt==1) double hi1 = upPrice[i-1];  
   if((opt==1 && (i==0 || (i > 0 /*&& hi0 > hi1*/)) && hi0 >= max) || (opt==0 && hi0 >= max)) {max = hi0; hibar = i;}
   }   

   return(hibar);
} 
 
string tf(int itimeframe)
{
   string result = "";
   
   switch(itimeframe)
   {
   case PERIOD_M1:   result = "M1" ;
   case PERIOD_M5:   result = "M5" ;
   case PERIOD_M15:  result = "M15";
   case PERIOD_M30:  result = "M30";
   case PERIOD_H1:   result = "H1" ;
   case PERIOD_H4:   result = "H4" ;
   case PERIOD_D1:   result = "D1" ;
   case PERIOD_W1:   result = "W1" ;
   case PERIOD_MN1:  result = "MN1";
   default:          result = "N/A";
   }
   
   if(result == "N/A")
   {
   if(itimeframe <  PERIOD_H1 ) result = "M"  + itimeframe;
   if(itimeframe >= PERIOD_H1 ) result = "H"  + itimeframe/PERIOD_H1;
   if(itimeframe >= PERIOD_D1 ) result = "D"  + itimeframe/PERIOD_D1;
   if(itimeframe >= PERIOD_W1 ) result = "W"  + itimeframe/PERIOD_W1;
   if(itimeframe >= PERIOD_MN1) result = "MN" + itimeframe/PERIOD_MN1;
   }
   
   return(result); 
}
//------------------------------------------- 

// HeikenAshi Price
double   haClose[2][2], haOpen[2][2], haHigh[2][2], haLow[2][2];
datetime prevhatime[2];

double HeikenAshi(int index,int price,int bar)
{ 
   if(prevhatime[index] != Time[bar])
   {
   haClose[index][1] = haClose[index][0];
   haOpen [index][1] = haOpen [index][0];
   haHigh [index][1] = haHigh [index][0];
   haLow  [index][1] = haLow  [index][0];
   prevhatime[index] = Time[bar];
   }
   
   if(bar == Bars - 1) 
   {
   haClose[index][0] = Close[bar];
   haOpen [index][0] = Open [bar];
   haHigh [index][0] = High [bar];
   haLow  [index][0] = Low  [bar];
   }
   else
   {
   haClose[index][0] = (Open[bar] + High[bar] + Low[bar] + Close[bar])/4;
   haOpen [index][0] = (haOpen[index][1] + haClose[index][1])/2;
   haHigh [index][0] = MathMax(High[bar],MathMax(haOpen[index][0],haClose[index][0]));
   haLow  [index][0] = MathMin(Low [bar],MathMin(haOpen[index][0],haClose[index][0]));
   }
   
   switch(price)
   {
   case  0: return(haClose[index][0]); break;
   case  1: return(haOpen [index][0]); break;
   case  2: return(haHigh [index][0]); break;
   case  3: return(haLow  [index][0]); break;
   case  4: return((haHigh[index][0] + haLow[index][0])/2); break;
   case  5: return((haHigh[index][0] + haLow[index][0] +   haClose[index][0])/3); break;
   case  6: return((haHigh[index][0] + haLow[index][0] + 2*haClose[index][0])/4); break;
   default: return(haClose[index][0]); break;
   }
}     


datetime prevnbtime;

bool isNewBar(int tf)
{
   bool res = false;
   
   if(tf >= 0)
   {
      if(iTime(NULL,tf,0) != prevnbtime)
      {
      res   = true;
      prevnbtime = iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

string prevmess;
 
bool BoxAlert(bool cond,string text)   
{      
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text;
   
   if (cond && mess != prevmess)
	{
	Alert (mess);
	prevmess = mess; 
	return(true);
	} 
  
   return(false);  
}

datetime pausetime;

bool Pause(int sec)
{
   if(TimeCurrent() >= pausetime + sec) {pausetime = TimeCurrent(); return(true);}
   
   return(false);
}

datetime warningtime;

void WarningSound(bool cond,int num,int sec,string sound,datetime curtime)
{
   static int i;
   
   if(cond)
   {
   if(curtime != warningtime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); warningtime = curtime; i++;}       	
   }
}

string prevemail;

bool EmailAlert(bool cond,string text1,string text2,int num)   
{      
   string subj = "New " + text1 +" Signal from " + IndicatorName + "!!!";    
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text2;
   
   if (cond && mess != prevemail)
	{
	if(subj != "" && mess != "") for(int i=0;i<num;i++) SendMail(subj, mess);  
	prevemail = mess; 
	return(true);
	} 
  
   return(false);  
}

string prevpush;
 
bool PushAlert(bool cond,string text)   
{      
   string push = IndicatorName + "("+Symbol() + "," + TF + ")" + text;
   
   if(cond && push != prevpush)
	{
	SendNotification(push);
	
	prevpush = push; 
	return(true);
	} 
  
   return(false);  
}


void plot123Pattern(string name,int ptrend,datetime time1,double value1,datetime time2,double value2,datetime time3,double value3,color clr,int width,double dist,int size)
{
   if(value1 > 0 && value2 > 0 && value3 > 0)
   { 
   plotLine(name+" line0",0,time1,value1,time2,value2,clr,width,0);
   plotLine(name+" line1",0,time2,value2,time3,value3,clr,width,0);
   
   
      if(ptrend > 0) 
      {
      plotText(name+" #3",0,time1,value1-dist,"Arial",size,"3",clr,ANCHOR_UPPER);
      plotText(name+" #2",0,time2,value2+dist,"Arial",size,"2",clr,ANCHOR_LOWER);
      plotText(name+" #1",0,time3,value3-dist,"Arial",size,"1",clr,ANCHOR_UPPER);
      }
   
      if(ptrend < 0) 
      {
      plotText(name+" #3",0,time1,value1+dist,"Arial",size,"3",clr,ANCHOR_LOWER);
      plotText(name+" #2",0,time2,value2-dist,"Arial",size,"2",clr,ANCHOR_UPPER);
      plotText(name+" #1",0,time3,value3+dist,"Arial",size,"1",clr,ANCHOR_LOWER);
      }
   }
}


void plotText(string name,int win,int time,double price,string font,int size,string text,color clr,int anchor)
{
   if(ObjectCreate(0,name,OBJ_TEXT,win,time,price)) 
   {
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetText(name,text,size,font,clr); 
   }
}

void plotLine(string name,int win,datetime time1,double value1,datetime time2,double value2,color clr,int width,int style)
{
   if(ObjectCreate(0,name,OBJ_TREND,win,time1,value1,time2,value2))
   {
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSet(name,OBJPROP_RAY  ,false);
   ObjectSet(name,OBJPROP_BACK ,false);
   ObjectSet(name,OBJPROP_COLOR,  clr);
   }  
} 

void moveLine(string name,int dir,int length)
{
   int loshift, hishift;
   double   zzlow, zzhigh;
   datetime time1, time2, lowtime, hightime;
   
   if(ObjectFind(0,name) >= 0)
   {
   time1 = ObjectGetInteger(0,name,OBJPROP_TIME,0);
   time2 = ObjectGetInteger(0,name,OBJPROP_TIME,1);
      
      if(dir < 0)
      {            
      loshift = iBarShift(NULL,0,time1);
      hishift = iBarShift(NULL,0,time2);
      zzlow   = loPrice[loshift];
      zzhigh  = upPrice[hishift];   
      }
      else
      {
      loshift = iBarShift(NULL,0,time2);
      hishift = iBarShift(NULL,0,time1);
      zzlow   = loPrice[loshift];
      zzhigh  = upPrice[hishift];   
      }
   
   lowtime  = Time[loshift];
   hightime = Time[hishift];
                  
      for(int i=1;i<length;i++) 
      {
         if(loPrice[loshift-i] < zzlow) 
         {
         zzlow   = loPrice[loshift-i];   
         lowtime = Time[loshift-i]; 
         }
                     
         if(upPrice[hishift-i] > zzhigh) 
         {
         zzhigh   = upPrice[hishift-i];   
         hightime = Time[hishift-i]; 
         }
      }  
   
      if(dir < 0)
      {            
      ObjectSetInteger(0,name,OBJPROP_TIME,0, lowtime);
      ObjectSetInteger(0,name,OBJPROP_TIME,1,hightime);
      }
      else
      {
      ObjectSetInteger(0,name,OBJPROP_TIME,0,hightime);
      ObjectSetInteger(0,name,OBJPROP_TIME,1, lowtime);
      }
   } 
}     
