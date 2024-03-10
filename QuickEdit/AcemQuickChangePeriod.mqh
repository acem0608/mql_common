//+------------------------------------------------------------------+
//|                                        AcemQuickChangePeriod.mqh |
//|                                             Copyright 2023, Acem |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property strict

#include <Acem/Common/AcemDefine.mqh>
#include <Acem/Common/AcemBase.mqh>

input string quickChagePreiod_dmy1 = "";//-- 時間軸の変更 --
input eInputKeyCode KEY_PERIOD_M5 = ACEM_KEYCODE_1; //　　5分足
input eInputKeyCode KEY_PERIOD_M15 = ACEM_KEYCODE_2; //　　15分足
input eInputKeyCode KEY_PERIOD_H1 = ACEM_KEYCODE_3; //　　1時間足
input eInputKeyCode KEY_PERIOD_H4 = ACEM_KEYCODE_4; //　　4時間足
input eInputKeyCode KEY_PERIOD_D1 = ACEM_KEYCODE_5; //　　日足

class CAcemQuickChangePeriod : CAcemBase
{
private:

public:
    CAcemQuickChangePeriod();
    ~CAcemQuickChangePeriod();
    virtual bool OnKeyDown(int id, long lparam, double dparam, string sparam);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickChangePeriod::CAcemQuickChangePeriod()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickChangePeriod::~CAcemQuickChangePeriod()
{
}
//+------------------------------------------------------------------+

bool CAcemQuickChangePeriod::OnKeyDown(int id, long lparam, double dparam, string sparam)
{
    ENUM_TIMEFRAMES period = ChartPeriod(ChartID());
    ENUM_TIMEFRAMES targetPeriod = period;

    if (lparam == KEY_PERIOD_D1) {
        targetPeriod = PERIOD_D1;
    }

    if (lparam == KEY_PERIOD_H4) {
        targetPeriod = PERIOD_H4;
    }

    if (lparam == KEY_PERIOD_H1) {
        targetPeriod = PERIOD_H1;
    }

    if (lparam == KEY_PERIOD_M15) {
        targetPeriod = PERIOD_M15;
    }

    if (lparam == KEY_PERIOD_M5) {
        targetPeriod = PERIOD_M5;
    }

    if (period != targetPeriod) {
        ChartSetSymbolPeriod(ChartID(), NULL, targetPeriod);
        ChartRedraw();
    }

    return true;
}