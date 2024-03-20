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

input string SLdmy1 = "";//-- ストップロスラインの設定 --
input eInputKeyCode KEY_SLLINE = ACEM_KEYCODE_Z;//　　水平線の入力キー
input eInputKeyCode KEY_TPLINE = ACEM_KEYCODE_X; //　　トレンドラインの入力キー

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
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickSLline::CAcemQuickSLline()
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
    return true;
}

