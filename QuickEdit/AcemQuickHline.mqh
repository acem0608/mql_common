//+------------------------------------------------------------------+
//|                                               AcemQuickHline.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Acem/QuickEdit/AcemQuickEditBase.mqh>
input string dmy1 = "";//-- 水平線の設定 --
input eInputKeyCode KEY_HLINE = ACEM_KEYCODE_H;//　　水平線の入力キー
input color HLINE_COLOR = 0x00FFFFFF;//　　色
input ENUM_LINE_STYLE HLINE_STYLE = STYLE_SOLID;//　　線種
input eLineidth HLINE_WIDTH = LINE_WIDTH_1;//　　線幅
input bool HLINE_BACK = false;//　　背景として表示

class CAcemQuickHline : public CAcemQuickEditBase
{
protected:
    string getNewObjName();
    long m_hlineIndex;

    virtual bool OnKeyDown(int id, long lparam, double dparam, string sparam);
    virtual bool setDefalutProp(string objName);
public:
    CAcemQuickHline();
    ~CAcemQuickHline();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickHline::CAcemQuickHline()
{
    m_hlineIndex = 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickHline::~CAcemQuickHline()
{
}
//+------------------------------------------------------------------+

bool CAcemQuickHline::OnKeyDown(int id, long lparam, double dparam, string sparam)
{
    if (lparam == KEY_HLINE) {
        string objName = getNewObjName();
        ObjectCreate(ChartID(), objName, OBJ_HLINE, 0, m_time, m_price);
        setDefalutProp(objName);
        ChartRedraw(ChartID());
        m_price = 0.0;
        m_time = 0;
    }
    return true;
}

string CAcemQuickHline::getNewObjName()
{
    string objName;
    do {
        objName = "Horizontal Line " + convettNumToStr05(m_hlineIndex++);
    } while (ObjectFind(ChartID(), objName) >= 0);

    return objName;
}

bool CAcemQuickHline::setDefalutProp(string objName)
{
    CAcemQuickEditBase::setDefalutProp(objName);
    ObjectSetInteger(ChartID(), objName, OBJPROP_COLOR, HLINE_COLOR);
    ObjectSetInteger(ChartID(), objName, OBJPROP_STYLE, HLINE_STYLE);
    ObjectSetInteger(ChartID(), objName, OBJPROP_WIDTH, HLINE_WIDTH);
    ObjectSetInteger(ChartID(), objName, OBJPROP_BACK, HLINE_BACK);
    return true;
}

