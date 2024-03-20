//+------------------------------------------------------------------+
//|                                              AcemQuickSLLint.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Acem/QuickEdit/AcemQuickEditBase.mqh>

input string SLdmy1 = "";//-- 損切り位置ライン入力の設定 --
input eInputKeyCode KEY_BIDSLLINE = ACEM_KEYCODE_X; //　桃ライン：売りの損切り位置の入力キー
input color SL_BID_COLOR = 0x00FF0000;  //  売り損切りラインの色
input eInputKeyCode KEY_ASKSLLINE = ACEM_KEYCODE_Z;//　青ライン：買いの損切り位置の入力キー
input color SL_ASK_COLOR = 0x000000FF;  //  買い損切りラインの色

class CAcemQuickSLline : public CAcemQuickEditBase
{
private:

public:
    CAcemQuickSLline();
    ~CAcemQuickSLline();
    
    virtual bool OnKeyDown(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectChange(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectDrag(int id, long lparam, double dparam, string sparam);
    virtual bool setDefalutProp(string objName);
    
    void addSlLine(color lineColor);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickSLline::CAcemQuickSLline(): CAcemQuickEditBase(ACEM_SLLINE_PREFIX)
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickSLline::~CAcemQuickSLline()
{
}
//+------------------------------------------------------------------+

bool CAcemQuickSLline::OnKeyDown(int id, long lparam, double dparam, string sparam)
{
    if (lparam == KEY_BIDSLLINE || lparam == KEY_ASKSLLINE) {
        color lineColor;
        if (lparam == KEY_BIDSLLINE) {
            lineColor = SL_BID_COLOR;
        } else {
            lineColor = SL_ASK_COLOR;
        }
        addSlLine(lineColor);
        ChartRedraw(ChartID());
    }


    return true;
}

bool CAcemQuickSLline::OnObjectChange(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickSLline::OnObjectDrag(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickSLline::setDefalutProp(string objName)
{
    ObjectSetInteger(ChartID(), objName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(ChartID(), objName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(ChartID(), objName, OBJPROP_BACK, false);
    ObjectSetInteger(ChartID(), objName, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, false);
#ifdef __MQL5__
   ObjectSetInteger(ChartID(), objName, OBJPROP_RAY_LEFT, false);
#endif

    return true;
}

void CAcemQuickSLline::addSlLine(color lineColor)
{
    string name = getNewObjName();
    datetime offsetTime = 5 * 4 * 60 * 60;
    ObjectCreate(ChartID(), name, OBJ_TREND, 0, m_time - offsetTime, m_price, m_time + offsetTime, m_price);
    ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, lineColor);
    
    string strPrice = DoubleToString(m_price);
    ObjectSetString(ChartID(), name, OBJPROP_TEXT, strPrice);

    setDefalutProp(name);
}
