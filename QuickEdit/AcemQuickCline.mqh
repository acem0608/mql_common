//+------------------------------------------------------------------+
//|                                               AcemQuickCline.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property strict

#include <Acem/QuickEdit/AcemQuickEditBase.mqh>
#include <ChartObjects/ChartObjectsChannels.mqh>

input eInputKeyCode KEY_CHANNEL = ACEM_KEYCODE_C;//平行チャネル

class CAcemQuickCline : public CAcemQuickEditBase
{
private:
    long m_channelIndex;
    CChartObjectChannel m_Channel;
    CChartObjectChannel *m_pChannel;
    int m_ChannelPointNum;

    virtual bool OnKeyDown(int id, long lparam, double dparam, string sparam);
    virtual bool OnMouseMove(int id, long lparam, double dparam, string sparam);
    virtual bool OnChartClick(int id, long lparam, double dparam, string sparam);

    bool init(bool bDel);

    string getNewObjName();

public:
    CAcemQuickCline();
    ~CAcemQuickCline();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickCline::CAcemQuickCline()
{
    m_channelIndex = 0;
    m_pChannel = NULL;
    m_ChannelPointNum = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickCline::~CAcemQuickCline()
{
}
//+------------------------------------------------------------------+

bool CAcemQuickCline::init(bool bDel)
{
    if (m_pChannel != NULL) {
        if (bDel) {
            m_Channel.Delete();
        }
        m_pChannel = NULL;
        m_ChannelPointNum = 0;
    }
    
    return true;
}

bool CAcemQuickCline::OnKeyDown(int id, long lparam, double dparam, string sparam)
{
    if (lparam == KEY_CHANNEL) {
        if (m_pChannel == NULL) {
            init(true);
            string objName = getNewObjName();
            m_pChannel = GetPointer(m_Channel);
            if (m_Channel.Create(ChartID(), objName, 0, m_time, m_price, m_time, m_price, m_time, m_price)) {
                ObjectSetInteger(ChartID(), objName, OBJPROP_READONLY, false);
                ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, false);
                ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, true);
                m_ChannelPointNum = 1;
            }
        }
    } else if (lparam == ACEM_KEYCODE_ESC) {
        init(true);
    }

    return true;
}
bool CAcemQuickCline::OnMouseMove(int id, long lparam, double dparam, string sparam)
{
    if (m_pChannel != NULL) {
        m_pChannel.SetPoint(m_ChannelPointNum, m_time, m_price);
        ChartRedraw(ChartID());
    }
    return true;
}

bool CAcemQuickCline::OnChartClick(int id, long lparam, double dparam, string sparam)
{
    if (m_pChannel != NULL) {
        if (m_ChannelPointNum == 2) {
            init(false);
        } else {
            m_ChannelPointNum++;
        }
    }
    return true;
}

string CAcemQuickCline::getNewObjName()
{
    string objName;
    do {
        objName = "Trend Line " + convettNumToStr05(m_channelIndex++);
    } while (ObjectFind(ChartID(), objName) >= 0);

    return objName;
}
