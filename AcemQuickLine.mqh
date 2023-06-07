//+------------------------------------------------------------------+
//|                                                AcemQuickLine.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define ACEM_KEY_ESC 27

#include <ChartObjects/ChartObjectsChannels.mqh>

enum eInputKey
{
    ACEM_KEY_A = 65, // A
    ACEM_KEY_B = 66, // B
    ACEM_KEY_C = 67, // C
    ACEM_KEY_D = 68, // D
    ACEM_KEY_E = 69, // E
    ACEM_KEY_F = 70, // F
    ACEM_KEY_G = 71, // G
    ACEM_KEY_H = 72, // H
    ACEM_KEY_I = 73, // I
    ACEM_KEY_J = 74, // J
    ACEM_KEY_K = 75, // K
    ACEM_KEY_L = 76, // L
    ACEM_KEY_M = 77, // M
    ACEM_KEY_N = 78, // N
    ACEM_KEY_O = 79, // O
    ACEM_KEY_P = 80, // P
    ACEM_KEY_Q = 81, // Q
    ACEM_KEY_R = 82, // R
    ACEM_KEY_S = 83, // S
    ACEM_KEY_T = 84, // T
    ACEM_KEY_U = 85, // U
    ACEM_KEY_V = 86, // V
    ACEM_KEY_W = 87, // W
    ACEM_KEY_X = 88, // X
    ACEM_KEY_Y = 89, // Y
    ACEM_KEY_Z = 90 // Z
};

input eInputKey KEY_HLINE = ACEM_KEY_H;//水平線
input eInputKey KEY_VLINE = ACEM_KEY_V;//垂直線
input eInputKey KEY_TLINE = ACEM_KEY_T;//トレンドライン
input eInputKey KEY_CHANNEL = ACEM_KEY_C;//平行チャネル
input eInputKey KEY_DELETE = ACEM_KEY_D;//削除

class CAcemQuickLine
{
private:
    long m_time;
    double m_price;
    long m_vlineIndex;
    long m_hlineIndex;
    long m_tlineIndex;
    long m_channelIndex;
    CChartObjectTrend m_Tline;
    CChartObjectTrend* m_pTline;
    CChartObjectChannel m_Channel;
    CChartObjectChannel* m_pChannel;
    int m_ChannelPointNum;
    
    string getVlineName();
    string getHlineName();
    string getTlineName();
    string getChannelName();
public:
    CAcemQuickLine();
    ~CAcemQuickLine();

    bool init(bool bDel);

    bool OnChartEvent(int id, long lparam, double dparam, string sparam);
    bool OnKeyDown(int id, long lparam, double dparam, string sparam);
    bool OnMouseMove(int id, long lparam, double dparam, string sparam);
    bool OnObjectCreate(int id, long lparam, double dparam, string sparam);
    bool OnObjectChange(int id, long lparam, double dparam, string sparam);
    bool OnObjectDelete(int id, long lparam, double dparam, string sparam);
    bool OnChartClick(int id, long lparam, double dparam, string sparam);
    bool OnObjectClick(int id, long lparam, double dparam, string sparam);
    bool OnObjectDrag(int id, long lparam, double dparam, string sparam);
    bool OnObjectEndEdit(int id, long lparam, double dparam, string sparam);
    bool OnChartChange(int id, long lparam, double dparam, string sparam);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickLine::CAcemQuickLine()
{
    m_time = 0;
    m_price = 0.0;
    m_hlineIndex = 0;
    m_vlineIndex = 0;
    m_tlineIndex = 0;
    m_channelIndex = 0;
    m_pTline = NULL;
    m_pChannel = NULL;
    m_ChannelPointNum = 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemQuickLine::~CAcemQuickLine()
{
}
//+------------------------------------------------------------------+

bool CAcemQuickLine::init(bool bDel)
{
    if (m_pTline != NULL) {
        if (bDel) {
            m_Tline.Delete();
        }
        m_pTline = NULL;
    }
    
    if (m_pChannel != NULL) {
        if (bDel) {
            m_Channel.Delete();
        }
        m_pChannel = NULL;
        m_ChannelPointNum = 0;
    }
    
    return true;
}

bool CAcemQuickLine::OnChartEvent(int id, long lparam, double dparam, string sparam)
{
    switch (id)
    {
    case CHARTEVENT_KEYDOWN:
        {
            OnKeyDown(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_MOUSE_MOVE:
        {
            OnMouseMove(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_OBJECT_CREATE:
        {
            OnObjectCreate(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_OBJECT_CHANGE:
        {
            OnObjectChange(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_OBJECT_DELETE:
        {
            OnObjectDelete(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_CLICK:
        {
            OnChartClick(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_OBJECT_CLICK:
        {
            OnMouseMove(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_OBJECT_DRAG:
        {
            OnObjectDrag(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_OBJECT_ENDEDIT:
        {
            OnObjectEndEdit(id, lparam, dparam, sparam);
        }
        break;
    case CHARTEVENT_CHART_CHANGE:
        {
            OnChartChange(id, lparam, dparam, sparam);
        }
        break;
    default:
        break;
    }
    return true;
}

bool CAcemQuickLine::OnKeyDown(int id, long lparam, double dparam, string sparam)
{
    if (lparam == KEY_VLINE && m_time != 0) {
        // 垂直線を追加
        string objName = getVlineName();
        ObjectCreate(ChartID(), objName, OBJ_VLINE, 0, m_time, m_price);
        ObjectSetInteger(ChartID(), objName, OBJPROP_READONLY, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, true);
        ChartRedraw(ChartID());
        m_price = 0.0;
        m_time = 0;
    } else if (lparam == KEY_HLINE && m_price != 0) {
        // 水平線を追加
        string objName = getHlineName();
        ObjectCreate(ChartID(), objName, OBJ_HLINE, 0, m_time, m_price);
        ObjectSetInteger(ChartID(), objName, OBJPROP_READONLY, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, false);
        ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, true);
        ChartRedraw(ChartID());
        m_price = 0.0;
        m_time = 0;
    } else if (lparam == KEY_TLINE) {
        if (m_pTline == NULL) {
            init(true);
            m_pTline = GetPointer(m_Tline);
            string objName = getTlineName();
            if (m_Tline.Create(ChartID(), objName, 0, m_time, m_price, m_time, m_price)) {
                ObjectSetInteger(ChartID(), objName, OBJPROP_READONLY, false);
                ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, false);
                ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, true);
            }
        }
    } else if (lparam == KEY_CHANNEL) {
        if (m_pChannel == NULL) {
            init(true);
            string objName = getChannelName();
            m_pChannel = GetPointer(m_Channel);
            if (m_Channel.Create(ChartID(), objName, 0, m_time, m_price, m_time, m_price, m_time, m_price)) {
                ObjectSetInteger(ChartID(), objName, OBJPROP_READONLY, false);
                ObjectSetInteger(ChartID(), objName, OBJPROP_HIDDEN, false);
                ObjectSetInteger(ChartID(), objName, OBJPROP_SELECTABLE, true);
                m_ChannelPointNum = 1;
            }
        }
    } else if (lparam == KEY_DELETE) {
        // 選択されているオブジェクトを削除
        int objectTotalNum = ObjectsTotal(ChartID());
        int index;
        string objectName;
        int deleteNum = 0;
        
        // 選択されているオブジェクト数を取得
        for (index = 0; index < objectTotalNum; index++) {
            objectName = ObjectName(ChartID(), index);
            if (ObjectGetInteger(ChartID(), objectName, OBJPROP_SELECTED) == true) {
                deleteNum++;
            }
        }
        
        // 選択されているオブジェクトの名前を配列に格納
        string aStrDeleteObjeName[];
        ArrayResize(aStrDeleteObjeName, deleteNum);
        int deleteIndex = 0;
        for (index = 0; index < objectTotalNum; index++) {
            objectName = ObjectName(ChartID(), index);
            if (ObjectGetInteger(ChartID(), objectName, OBJPROP_SELECTED) == true) {
                aStrDeleteObjeName[deleteIndex++] = objectName;
            }
        }
        
        // 配列に格納されたオブジェクトの削除
        for (index = 0; index < deleteNum; index++) {
            ObjectDelete(ChartID(), aStrDeleteObjeName[index]);
        }
        ChartRedraw(ChartID());
    } else if (lparam == ACEM_KEY_ESC) {
        init(true);
    }
    return true;
}

bool CAcemQuickLine::OnMouseMove(int id, long lparam, double dparam, string sparam)
{
    int windowNo;
    datetime mouseTime;
    double mousePrice;
    if (!ChartXYToTimePrice(ChartID(), lparam, dparam, windowNo, mouseTime, mousePrice))
    {
        return false;
        m_price = 0.0;
        m_time = 0;
    }
    
    m_price = mousePrice;
    m_time = mouseTime;

    if (m_pTline != NULL) {
        m_Tline.SetPoint(1, m_time, m_price);
        ChartRedraw(ChartID());
    }
    if (m_pChannel != NULL) {
        m_pChannel.SetPoint(m_ChannelPointNum, m_time, m_price);
        ChartRedraw(ChartID());
    }
    
    return true;
}

bool CAcemQuickLine::OnObjectCreate(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickLine::OnObjectChange(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickLine::OnObjectDelete(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickLine::OnChartClick(int id, long lparam, double dparam, string sparam)
{
    if (m_pTline != NULL) {
        init(false);
    }
    if (m_pChannel != NULL) {
        if (m_ChannelPointNum == 2) {
            init(false);
        } else {
            m_ChannelPointNum++;
        }
    }
    
    return true;
}

bool CAcemQuickLine::OnObjectClick(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickLine::OnObjectDrag(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickLine::OnObjectEndEdit(int id, long lparam, double dparam, string sparam)
{
    return true;
}

bool CAcemQuickLine::OnChartChange(int id, long lparam, double dparam, string sparam)
{
    return true;
}


string CAcemQuickLine::getVlineName()
{
    string objName;
    do {
        objName = "VLine " + m_vlineIndex++;
    } while (ObjectFind(ChartID(), objName) >= 0);

    return objName;
}

string CAcemQuickLine::getHlineName()
{
    string objName;
    do {
        objName = "HLine " + m_hlineIndex++;
    } while (ObjectFind(ChartID(), objName) >= 0);

    return objName;
}

string CAcemQuickLine::getTlineName()
{
    string objName;
    do {
        objName = "TrendLine " + m_tlineIndex++;
    } while (ObjectFind(ChartID(), objName) >= 0);

    return objName;
}

string CAcemQuickLine::getChannelName()
{
    string objName;
    do {
        objName = "Channel " + m_channelIndex++;
    } while (ObjectFind(ChartID(), objName) >= 0);

    return objName;
}

