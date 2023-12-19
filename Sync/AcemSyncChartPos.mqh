//+------------------------------------------------------------------+
//|                                             AcemSyncChartPos.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#ifndef _ACEM_DEBUG
#define _ACEM_DEBUG
#endif

#include <ChartObjects/ChartObjectsLines.mqh>
#include <Acem/Common/AcemBase.mqh>
#include <Acem/Common/AcemDefine.mqh>
#include <Acem/Common/AcemUtility.mqh>
#include <Acem/Draw/AcemHideRightSide.mqh>

#define ACEM_SYNC_BASE_RATIO_PREFIX "AcemBaseLineRatio"

input string AcemSyncPos = "";                                 //-- 基準線の設定 --
input color ACEM_SYNC_POS_BASE_LINE_COLOR = 0x00FFFFFF;        // 　　色
input ENUM_LINE_STYLE ACEM_SYNC_POS_BASE_LINE = STYLE_SOLID;   // 　　線種
input eLineWidth ACEM_SYNC_POS_BASE_LINE_WIDTH = LINE_WIDTH_1; // 　　線幅
input bool IS_HIDE_RIGHT = true;                               // 　　基準線の右側を隠す

class CAcemSyncChartPos : public CAcemBase
{
protected:
    CAcemHideRightSide m_hideRight;
    datetime m_baseTime;
    int m_baseXPos;
    string m_strGlobalBaseOffsetRatio;
    double m_baseOffsetRatio;
    int m_baseIndex;
    ENUM_TIMEFRAMES m_period;
    int m_chartBarNum;

    int getOffsetIndex(int offset);
    void setOffsetRatio();
    void outputParm();
    void deleteParm();
    void setBaseLineProp();

public:
    CAcemSyncChartPos();
    ~CAcemSyncChartPos();

    virtual bool OnObjectChange(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectDelete(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectDrag(int id, long lparam, double dparam, string sparam);
    virtual bool OnChartChange(int id, long lparam, double dparam, string sparam);
    virtual bool OnCustomEvent(int id, long lparam, double dparam, string sparam);

    void init();
    void deinit(const int reason);
    void shiftChartToBaseLine();
    void shiftChartToBaseLineOtherChart(long chartId, datetime currentTime);
    void shiftBaseIndexToBasePos(long chartId);
    void moveBaseLineToBasePos(long chartId);
    void syncOtherChart();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemSyncChartPos::CAcemSyncChartPos()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemSyncChartPos::~CAcemSyncChartPos()
{
}
//+------------------------------------------------------------------+

void CAcemSyncChartPos::init()
{
#ifndef _ACEM_DEBUG
#endif

    int objNum = ObjectsTotal(ChartID());
    int i;
    for (i = 0; i < objNum; i++)
    {
        string objName = ObjectName(ChartID(), i, 0);
        int z_order = ObjectGetInteger(ChartID(), objName, OBJPROP_ZORDER);
        if (z_order == 0)
        {
            ObjectSetInteger(ChartID(), objName, OBJPROP_ZORDER, 10);
        }
    }
    m_hideRight.init();
    long chartId = ChartID();
    m_chartBarNum = WindowBarsPerChart();
    m_strGlobalBaseOffsetRatio = ACEM_SYNC_BASE_RATIO_PREFIX + chartId;
    ChartSetInteger(chartId, CHART_AUTOSCROLL, false);
    m_baseOffsetRatio = 0.5;
    if (GlobalVariableCheck(m_strGlobalBaseOffsetRatio))
    {
        m_baseOffsetRatio = GlobalVariableGet(m_strGlobalBaseOffsetRatio);
    }

    int baseOffset = MathRound(WindowBarsPerChart() * m_baseOffsetRatio);
    m_baseIndex = getOffsetIndex(baseOffset);
    m_baseXPos = convIndexToPosX(chartId, m_baseIndex);
    m_baseTime = convIndexToTime(chartId, m_baseIndex);
    long targetId;
    datetime baseTime = 0;
    if (ObjectFind(chartId, ACEM_SYNC_BASE_LINE_NAME) < 0)
    {
        // 現在のチャートの中心にラインを追加
        ObjectCreate(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJ_VLINE, 0, m_baseTime, 0, 0);

        for (targetId = ChartFirst(); targetId != -1; targetId = ChartNext(targetId))
        {
            if (targetId == ChartID())
            {
                continue;
            }

            // 基準線がないのは対象外
            if (ObjectFind(targetId, ACEM_SYNC_BASE_LINE_NAME) < 0)
            {
                continue;
            }
            baseTime = ObjectGetInteger(targetId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
            break;
        }
    }
    else
    {
        baseTime = ObjectGetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    }

    if (baseTime != 0)
    {
        // 他のチャートに基準線がある場合はそれに時間を合わせる画面移動
        ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, baseTime);
        m_baseTime = baseTime;
        datetime currentTime = ObjectGetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
        int currentIndex = convTimeToIndex(chartId, currentTime);
        int shift = m_baseIndex - currentIndex;
        // m_baseXPos = convTimeToPosX(chartId, currentTime);
        ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
        ChartNavigate(chartId, CHART_CURRENT_POS, shift);
        ChartRedraw(chartId);
    }
    // 初期化処理
    m_period = ChartPeriod(chartId);
    ObjectSetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_ZORDER, 1);

    ObjectSetInteger(ChartID(), ACEM_CHART_HIDE_CANVAS, OBJPROP_SELECTABLE, false);
    m_hideRight.Resize();
    m_hideRight.Erase();
    if (IS_HIDE_RIGHT)
    {
        m_hideRight.setHidePos(m_baseXPos);
    }

    ObjectSetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_ZORDER, 2);
    ObjectSetInteger(ChartID(), ACEM_CHART_HIDE_CANVAS, OBJPROP_ZORDER, 1);

    setBaseLineProp();
}

void CAcemSyncChartPos::deinit(const int reason)
{
#ifndef _ACEM_DEBUG
#endif

    if (reason != REASON_INITFAILED)
    {
        outputParm();
    }

    switch (reason)
    {
    case REASON_REMOVE:
    {
        ObjectDelete(ChartID(), ACEM_SYNC_BASE_LINE_NAME);
        m_hideRight.deinit();
        ObjectDelete(ChartID(), ACEM_CHART_HIDE_CANVAS);
        ChartRedraw(ChartID());
    }
    break;
    case REASON_PROGRAM:
    case REASON_CHARTCLOSE:
    case REASON_CLOSE:
    case REASON_RECOMPILE:
    case REASON_CHARTCHANGE:
    case REASON_PARAMETERS:
    case REASON_ACCOUNT:
    case REASON_TEMPLATE:
    case REASON_INITFAILED:
    default:
    {
    }
    break;
    }

    // m_hideRight.deinit();
}

bool CAcemSyncChartPos::OnObjectChange(int id, long lparam, double dparam, string sparam)
{
#ifndef _ACEM_DEBUG
#endif

    if (sparam == ACEM_SYNC_BASE_LINE_NAME)
    {
        long chartId = ChartID();
        if (ChartGetInteger(chartId, CHART_BRING_TO_TOP))
        {
            shiftBaseIndexToBasePos(chartId);
        }
    }
    return true;
}

bool CAcemSyncChartPos::OnObjectDelete(int id, long lparam, double dparam, string sparam)
{
#ifndef _ACEM_DEBUG
#endif

    if (sparam == ACEM_SYNC_BASE_LINE_NAME)
    {
        long chartId = ChartID();
        ObjectCreate(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJ_VLINE, 0, m_baseTime, 0, 0);
        setBaseLineProp();
    }
    return true;
}

bool CAcemSyncChartPos::OnObjectDrag(int id, long lparam, double dparam, string sparam)
{
#ifndef _ACEM_DEBUG
#endif

    if (sparam == ACEM_SYNC_BASE_LINE_NAME)
    {
        if (ChartGetInteger(ChartID(), CHART_BRING_TO_TOP))
        {
            shiftChartToBaseLine();
            setOffsetRatio();
        }
    }
    return true;
}

bool CAcemSyncChartPos::OnChartChange(int id, long lparam, double dparam, string sparam)
{
#ifndef _ACEM_DEBUG
#endif

    if (m_chartBarNum != WindowBarsPerChart())
    {
        m_chartBarNum = WindowBarsPerChart();
        int baseOffset = MathRound(WindowBarsPerChart() * m_baseOffsetRatio);
        int leftIndex = WindowFirstVisibleBar();
        int shift = (leftIndex - m_baseIndex) - baseOffset;
        m_baseXPos = convIndexToPosX(ChartID(), leftIndex - baseOffset);
        ChartNavigate(ChartID(), CHART_CURRENT_POS, -shift);
    }
    else
    {
        if (ChartGetInteger(ChartID(), CHART_BRING_TO_TOP))
        {
            moveBaseLineToBasePos(ChartID());
            syncOtherChart();
        }
        else
        {
            moveBaseLineToBasePos(ChartID());
        }
    }

    m_hideRight.Resize();
    if (IS_HIDE_RIGHT)
    {
        m_hideRight.setHidePos(m_baseXPos);
    }
    ChartRedraw(ChartID());
    return true;
}

bool CAcemSyncChartPos::OnCustomEvent(int id, long lparam, double dparam, string sparam)
{
#ifndef _ACEM_DEBUG
#endif

    if ("AcemChartSync" == sparam)
    {
        m_baseTime = ObjectGetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
        int targetIndex = convTimeToIndex(ChartID(), m_baseTime);
        int shift = m_baseIndex - targetIndex;
        m_baseIndex = targetIndex;
        ChartNavigate(ChartID(), CHART_CURRENT_POS, shift);
        ChartRedraw(ChartID());
    }
    return true;
}

// 基準線の位置がX座標の位置になるようにチャートをシフトする
void CAcemSyncChartPos::shiftChartToBaseLine()
{
#ifndef _ACEM_DEBUG
#endif

    long chartId = ChartID();
    datetime currentTime = (datetime)ObjectGetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    int currentIndex = convTimeToIndex(chartId, currentTime);
    int shift = m_baseIndex - currentIndex;
    m_baseXPos = convTimeToPosX(chartId, currentTime);
    if (IS_HIDE_RIGHT)
    {
        m_hideRight.setHidePos(m_baseXPos);
    }
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
    ChartNavigate(chartId, CHART_CURRENT_POS, -shift);
    ChartRedraw(chartId);
}

void CAcemSyncChartPos::shiftChartToBaseLineOtherChart(long chartId, datetime currentTime)
{
#ifndef _ACEM_DEBUG
#endif

    datetime baseTime = (datetime)ObjectGetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    int baseIndex = convTimeToIndex(chartId, baseTime);
    int shift = baseIndex - convTimeToIndex(chartId, currentTime);
    ChartNavigate(chartId, CHART_CURRENT_POS, shift);
    ChartRedraw(chartId);
}

void CAcemSyncChartPos::shiftBaseIndexToBasePos(long chartId)
{
#ifndef _ACEM_DEBUG
#endif

    datetime currentTime = (datetime)ObjectGetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    int currentIndex = convTimeToIndex(chartId, currentTime);
    int shift = m_baseIndex - currentIndex;
    m_baseIndex = currentIndex;
    m_baseTime = currentTime;
    ChartNavigate(chartId, CHART_CURRENT_POS, shift);
    ChartRedraw(chartId);
}

// 基準線をX座標の位置となるように時間を設定する。
void CAcemSyncChartPos::moveBaseLineToBasePos(long chartId)
{
#ifndef _ACEM_DEBUG
#endif

    m_baseTime = convPosXToTime(chartId, m_baseXPos);
    m_baseIndex = convPosXToIndex(chartId, m_baseXPos);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
    ChartRedraw(chartId);
}

int CAcemSyncChartPos::getOffsetIndex(int offset)
{
#ifndef _ACEM_DEBUG
#endif

    int leftIndex = WindowFirstVisibleBar();
    int offsetIndex = leftIndex - offset;

    return offsetIndex;
}

void CAcemSyncChartPos::syncOtherChart()
{
#ifndef _ACEM_DEBUG
#endif

    // Print(ChartID()+" : " + m_baseIndex);
    long targetId;
    for (targetId = ChartFirst(); targetId != -1; targetId = ChartNext(targetId))
    {
        if (targetId == ChartID())
        {
            continue;
        }

        if (ChartSymbol(ChartID()) != ChartSymbol(targetId))
        {
            continue;
        }

        // 基準線がないのは対象外
        if (ObjectFind(targetId, ACEM_SYNC_BASE_LINE_NAME) < 0)
        {
            continue;
        }

        ObjectSetInteger(targetId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
        EventChartCustom(targetId, 0, 0, 0.0, "AcemChartSync");

        // shiftChartToBaseLineOtherChart(targetId, m_baseTime);
        ChartRedraw(targetId);
    }
}

void CAcemSyncChartPos::setOffsetRatio()
{
#ifndef _ACEM_DEBUG
#endif

    int width = WindowBarsPerChart();
    int leftIndex = WindowFirstVisibleBar();
    int indexPos = leftIndex - m_baseIndex;
    m_baseOffsetRatio = (double)indexPos / (double)width;
    GlobalVariableSet(m_strGlobalBaseOffsetRatio, m_baseOffsetRatio);
}

void CAcemSyncChartPos::outputParm()
{
#ifndef _ACEM_DEBUG
#endif

    GlobalVariableSet(m_strGlobalBaseOffsetRatio, m_baseOffsetRatio);
}

void CAcemSyncChartPos::deleteParm()
{
#ifndef _ACEM_DEBUG
#endif

    GlobalVariableDel(m_strGlobalBaseOffsetRatio);
}

void CAcemSyncChartPos::setBaseLineProp()
{
#ifndef _ACEM_DEBUG
#endif

    long chartId = ChartID();
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_READONLY, false);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_HIDDEN, false);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_COLOR, ACEM_SYNC_POS_BASE_LINE_COLOR);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_STYLE, ACEM_SYNC_POS_BASE_LINE);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_WIDTH, ACEM_SYNC_POS_BASE_LINE_WIDTH);
    ChartRedraw(chartId);
}
