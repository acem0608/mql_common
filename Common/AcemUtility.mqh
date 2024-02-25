//+------------------------------------------------------------------+
//|                                                  AcemUtility.mph |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link      "https://www.mql5.com"
#property strict

#include <Acem/Common/AcemMql4Emurator.mqh>
#include <Acem/Common/AcemDebug.mqh>
#include <Acem/Common/AcemDefine.mqh>

#ifndef ACEM_UTILITY
#define ACEM_UTILITY

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

bool isChartReady(long chartId)
{
    long barNum;
    if (!ChartGetInteger(chartId,CHART_VISIBLE_BARS, 0, barNum)) {
        return false;
    }
    if (barNum == 0) {
        return false;
    }
    
    return true;
}


bool convIndexToPosX(long chartId, int index, int& posX)
{
    if (!isChartReady(chartId)) {
        return false;
    }

    double price = 1.0;
    datetime time;
    if (!convIndexToTime(chartId, index, time)) {
        return false;
    }
    if (!convTimeToPosX(chartId, time, false, posX)) {
        return false;
    }

    return true;
}

bool convIndexToTime(long chartId, int index, datetime& time)
{
    if (!isChartReady(chartId)) {
        return false;
    }

    time = iTime(ChartSymbol(chartId), ChartPeriod(chartId), index);

    return true;
}

bool convPosXToIndex(long chartId, int x, int& index)
{
debugPrint(__FUNCTION__ + " Start");
    if (!isChartReady(chartId)) {
        return false;
    }

    int leftIndex = WindowFirstVisibleBar();    
    int chartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
    int step = int(1 << chartScale);
    int stepNum = (int)MathRound((double)x / (double)step);
debugPrint(__FUNCTION__ + " stepNum: " + IntegerToString(stepNum));
    index = leftIndex - stepNum;

debugPrint(__FUNCTION__ + " End");
    return true;
}

bool convPosXToTime(long chartId, int x, bool bRound, datetime& convTime)
{
    if (!isChartReady(chartId)) {
        return false;
    }

    int leftIndex = WindowFirstVisibleBar();
    datetime leftTime = iTime(NULL, 0, leftIndex);
    int chartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
    int step = int(1 << chartScale);
    int stepNum = int(x / step);
    int periodSec = PeriodSeconds(PERIOD_CURRENT);
    int convTimeIndex;
    int mod;

    if (leftIndex < stepNum) {
        convTimeIndex = 0;
        mod = x - (leftIndex * step);
    } else {
        convTimeIndex = leftIndex - stepNum;
        mod = x - (stepNum * step);
    }
    datetime baseTime = iTime(NULL, 0, convTimeIndex);
    datetime modTime;
    if (bRound) {
        modTime = 0;
    } else {
        modTime = datetime(mod * periodSec / step);
    }
    convTime = baseTime + modTime;

    return true;
}

bool convTimeToPosX(long chartId, datetime time, bool bRound, int& convX)
{
    if (!isChartReady(chartId)) {
        return false;
    }

    int leftIndex = WindowFirstVisibleBar();
    int nearIndex;
    if (!getNearIndex(chartId, time, nearIndex)) {
        return false;
    }
    int chartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
    int step = int(1 << chartScale);
    int stepNum = leftIndex - nearIndex;
    datetime nearTime = iTime(NULL, 0, nearIndex);
    datetime diffTime = time - nearTime;
    int periodSec = PeriodSeconds(PERIOD_CURRENT);
    double diffStepNum = (double)(diffTime / (double)periodSec);
    int diffX = (int)MathRound(diffStepNum * step);
    convX = (stepNum * step);
    if (!bRound) {
        convX += diffX;
    }

    return true;
}

bool convTimeToIndex(long chartId, datetime time, int& index)
{
    if (!isChartReady(chartId)) {
        return false;
    }

#ifndef __MQL5__
    int periodSec = PeriodSeconds(PERIOD_CURRENT);
    time = time + (periodSec / 2);
#endif
    index = iBarShift(ChartSymbol(chartId), ChartPeriod(chartId), time, false);
    
    return true;
}

bool getNearIndex(long chartId, datetime time, int& nearIndex) {
    if (!isChartReady(chartId)) {
        return false;
    }

 #ifdef __MQL4__
    nearIndex = iBarShift(NULL, 0, time, false);
 #endif
 #ifdef __MQL5__
    int periodSec = PeriodSeconds(PERIOD_CURRENT);
    nearIndex = iBarShift(NULL, 0, time + (periodSec / 2), false);
 #endif
 
    return true;
}

bool shiftOnGridX(long chartId, int x, int& shiftX)
{
debugPrint(__FUNCTION__ + " Start");
    if (!isChartReady(chartId)) {
debugPrint(__FUNCTION__ + " End : isChartReady false");
        return false;
    }

    int index;
    if (!convPosXToIndex(chartId, x, index)) {
debugPrint(__FUNCTION__ + " End : convPosXToIndex false");
        return false;
    }

    if (!convIndexToPosX(chartId, index, shiftX)) {
debugPrint(__FUNCTION__ + " End : convIndexToPosX false");
        return false;
    }

debugPrint(__FUNCTION__ + " End");
    return true;
}

bool shiftOnGridTime(long chartId, datetime time, datetime& shiftTime)
{
    if (!isChartReady(chartId)) {
        return false;
    }

    int index;
    if(!convTimeToIndex(chartId, time, index)) {
        return false;
    }
    if (!convIndexToTime(chartId, index, shiftTime)) {
        return false;
    }

    return true;
}

bool isSameIndicator(long chartId, string checkName)
{
    int indicatorNum = ChartIndicatorsTotal(chartId, 0);
    int i;
    int indiNum = 0;
    for (i = 0; i < indicatorNum; i++) {
        string indiName = ChartIndicatorName(chartId, 0, i);
        if (indiName == checkName) {
          indiNum++;
        }
    }
    
    if (indiNum > 1)
    {
        return true;
    }

    return false;
}

bool cloneObject(long fromChartId, string fromObjName, long toChartId, string toObjName)
{
    if (ObjectFind(toChartId, toObjName) >= 0) {
        return false;
    }

    long objType;
    double price1;
    double price2;
    double price3;
    datetime time1;
    datetime time2;
    datetime time3;
    ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TYPE, 0, objType);
    ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIME, 0, time1);
    ObjectGetDouble(fromChartId, fromObjName, OBJPROP_PRICE,  0, price1);
    ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIME, 1, time2);
    ObjectGetDouble(fromChartId, fromObjName, OBJPROP_PRICE,  1, price2);
    ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIME, 2, time3);
    ObjectGetDouble(fromChartId, fromObjName, OBJPROP_PRICE,  2, price3);
    
    ObjectCreate(toChartId, toObjName, (ENUM_OBJECT)objType, 0, time1, price1, time2, price2, time3, price3);

    setSameProp(fromChartId, fromObjName, toChartId, toObjName);
    
    return true;
}

void setSameProp(long fromChartId, string fromObjName, long toChartId, string toObjName)
{
    if (ObjectFind(toChartId, toObjName) < 0) {
        return;
    }
    
    //Integerの設定
    long intVal;
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_COLOR, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_COLOR, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_STYLE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_STYLE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_WIDTH, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_WIDTH, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_BACK, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_BACK, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_ZORDER, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_ZORDER, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_FILL, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_FILL, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_HIDDEN, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_HIDDEN, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_STYLE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_STYLE, 0, intVal);
    }
    
    // 非選択とする
    //if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_SELECTED, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_SELECTED, 0, false);
    //}
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_SELECTED, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_SELECTED, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIME, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_TIME, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIME, 1, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_TIME, 1, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIME, 2, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_TIME, 2, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_SELECTABLE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_SELECTABLE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_LEVELS, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_LEVELS, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_LEVELCOLOR, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_LEVELCOLOR, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_LEVELSTYLE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_LEVELSTYLE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_LEVELWIDTH, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_LEVELWIDTH, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_ALIGN, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_ALIGN, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_FONTSIZE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_FONTSIZE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_RAY_RIGHT, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_RAY_RIGHT, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_ELLIPSE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_ELLIPSE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_ARROWCODE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_ARROWCODE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_TIMEFRAMES, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_TIMEFRAMES, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_ANCHOR, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_ANCHOR, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_XDISTANCE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_XDISTANCE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_YDISTANCE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_YDISTANCE, 0, intVal);
    }
//    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_DRAWLINES, 0, intVal)) {
//        ObjectSetInteger(toChartId, toObjName, OBJPROP_DRAWLINES, 0, intVal);
//    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_STATE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_STATE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_XSIZE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_XSIZE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_YSIZE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_YSIZE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_XOFFSET, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_XOFFSET, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_YOFFSET, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_YOFFSET, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_BGCOLOR, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_BGCOLOR, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_CORNER, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_CORNER, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_BORDER_TYPE, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_BORDER_TYPE, 0, intVal);
    }
    if (ObjectGetInteger(fromChartId, fromObjName, OBJPROP_BORDER_COLOR, 0, intVal)) {
        ObjectSetInteger(toChartId, toObjName, OBJPROP_BORDER_COLOR, 0, intVal);
    }

    //Doubleの設定
    double dooubleVal;
    if (ObjectGetDouble(fromChartId, fromObjName, OBJPROP_PRICE, 0, dooubleVal)) {
        ObjectSetDouble(toChartId, toObjName, OBJPROP_PRICE, 0, dooubleVal);
    }
    if (ObjectGetDouble(fromChartId, fromObjName, OBJPROP_PRICE, 1, dooubleVal)) {
        ObjectSetDouble(toChartId, toObjName, OBJPROP_PRICE, 1, dooubleVal);
    }
    if (ObjectGetDouble(fromChartId, fromObjName, OBJPROP_PRICE, 2, dooubleVal)) {
        ObjectSetDouble(toChartId, toObjName, OBJPROP_PRICE, 2, dooubleVal);
    }
    if (ObjectGetDouble(fromChartId, fromObjName, OBJPROP_LEVELVALUE, 0, dooubleVal)) {
        ObjectSetDouble(toChartId, toObjName, OBJPROP_LEVELVALUE, 0, dooubleVal);
    }
    if (ObjectGetDouble(fromChartId, fromObjName, OBJPROP_ANGLE, 0, dooubleVal)) {
        ObjectSetDouble(toChartId, toObjName, OBJPROP_ANGLE, 0, dooubleVal);
    }
    if (ObjectGetDouble(fromChartId, fromObjName, OBJPROP_DEVIATION, 0, dooubleVal)) {
        ObjectSetDouble(toChartId, toObjName, OBJPROP_DEVIATION, 0, dooubleVal);
    }
    
    //文字列の設定
    string strVal;
    if (ObjectGetString(fromChartId, fromObjName, OBJPROP_TEXT, 0, strVal)) {
        ObjectSetString(toChartId, toObjName, OBJPROP_TEXT, 0, strVal);
    }
    if (ObjectGetString(fromChartId, fromObjName, OBJPROP_TOOLTIP, 0, strVal)) {
        ObjectSetString(toChartId, toObjName, OBJPROP_TOOLTIP, 0, strVal);
    }
    if (ObjectGetString(fromChartId, fromObjName, OBJPROP_LEVELTEXT, 0, strVal)) {
        ObjectSetString(toChartId, toObjName, OBJPROP_LEVELTEXT, 0, strVal);
    }
    if (ObjectGetString(fromChartId, fromObjName, OBJPROP_FONT, 0, strVal)) {
        ObjectSetString(toChartId, toObjName, OBJPROP_FONT, 0, strVal);
    }
    if (ObjectGetString(fromChartId, fromObjName, OBJPROP_BMPFILE, 0, strVal)) {
        ObjectSetString(toChartId, toObjName, OBJPROP_BMPFILE, 0, strVal);
    }
}

void setParamText(long chart_id, string paramObjName, long value)
{
    string strValue;
    strValue = IntegerToString(value);
    if (ObjectFind(chart_id, paramObjName) < 0) {
        ObjectCreate(chart_id, paramObjName, OBJ_TEXT, 0, 0, 0);
        ObjectSetInteger(chart_id, paramObjName, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
    }

    ObjectSetString(chart_id, paramObjName, OBJPROP_TEXT, strValue);
}

bool getParamValue(long chart_id, string paramObjName, int& value)
{
    long longValue;
    if (getParamValue(chart_id, paramObjName, longValue)) {
        return false;
    }
    
    value = (int)longValue;
    return true;
}

bool getParamValue(long chart_id, string paramObjName, long& value)
{
    if (ObjectFind(chart_id, paramObjName) < 0) {
        return false;
    }
    
    string strValue;
    if (!ObjectGetString(chart_id, paramObjName, OBJPROP_TEXT, 0, strValue)) {
        return false;
    }

    value = StringToInteger(strValue);
    return true;
}

datetime convChartTimeToLocalTime(datetime chartTime, eGmtTime chartGmt, eGmtTime localGmt, eSummerTime mode)
{
    int diff = localGmt - chartGmt;
    
    int summerTime = 0;
    if (isSummerTime(chartTime, mode)) {
        summerTime = 1;
    }
    datetime localTime = chartTime + ((localGmt - (chartGmt + summerTime)) * 3600);
    return localTime;
}

datetime convLocalTimeToChartTime(datetime chartTime, eGmtTime chartGmt, eGmtTime localGmt, eSummerTime mode)
{
    int diff = localGmt - chartGmt;
    int summerTime = 0;
    if (isSummerTime(chartTime, mode)) {
        summerTime = 1;
    }
    datetime localTime = chartTime + (((chartGmt + summerTime) - localGmt) * 3600);
    return localTime;
}

bool isSummerTime(datetime time, eSummerTime mode)
{
    switch (mode) {
        case SUMMER_TIME_NONE:
        {
            return false;
        }
        break;
        case SUMMER_TIME_AMERICA:
        {
        }
        break;
        case SUMMER_TIME_LONDON:
        {
        }
        break;
        case SUMMER_TIME_OCEANIA:
        {
        }
        break;
        default:
        {
        }
        break;
    }
    return false;
}
#endif