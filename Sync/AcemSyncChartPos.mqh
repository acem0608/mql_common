//+------------------------------------------------------------------+
//|                                             AcemSyncChartPos.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <ChartObjects/ChartObjectsLines.mqh>
#include <Acem/Common/AcemBase.mqh>
#include <Acem/Common/AcemDefine.mqh>
#include <Acem/Common/AcemUtility.mqh>
#include <Acem/Common/AcemDebug.mqh>

#define ACEM_SYNC_BASE_RATIO_PREFIX "AcemBaseLineRatio"

input string AcemSyncPos = "";                                 //-- 基準線の設定 --
input color ACEM_SYNC_POS_BASE_LINE_COLOR = 0x00FFFFFF;        // 　　色
input ENUM_LINE_STYLE ACEM_SYNC_POS_BASE_LINE = STYLE_SOLID;   // 　　線種
input eLineWidth ACEM_SYNC_POS_BASE_LINE_WIDTH = LINE_WIDTH_1; // 　　線幅
input bool IS_HIDE_RIGHT = true;                               // 　　基準線の右側を隠す

class CAcemSyncChartPos : public CAcemBase
{
protected:
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
    debugPrint("void CAcemSyncChartPos::init()");

    long chartId = ChartID();
    m_chartBarNum = WindowBarsPerChart();
    m_strGlobalBaseOffsetRatio = ACEM_SYNC_BASE_RATIO_PREFIX + IntegerToString(chartId);
    ChartSetInteger(chartId, CHART_AUTOSCROLL, false);
    m_baseOffsetRatio = 0.5;
    if (GlobalVariableCheck(m_strGlobalBaseOffsetRatio)) {
        m_baseOffsetRatio = GlobalVariableGet(m_strGlobalBaseOffsetRatio);
    }

    int baseOffset = (int)MathRound(WindowBarsPerChart() * m_baseOffsetRatio);
    m_baseIndex = getOffsetIndex(baseOffset);
    m_baseXPos = convIndexToPosX(chartId, m_baseIndex);
    m_baseTime = convIndexToTime(chartId, m_baseIndex);
    long targetId;
    datetime baseTime = 0;
    if (ObjectFind(chartId, ACEM_SYNC_BASE_LINE_NAME) < 0) {
        // 現在のチャートの中心にラインを追加
        ObjectCreate(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJ_VLINE, 0, m_baseTime, 0, 0);

        for (targetId = ChartFirst(); targetId != -1; targetId = ChartNext(targetId)) {
            if (targetId == ChartID()) {
                continue;
            }

            // 基準線がないのは対象外
            if (ObjectFind(targetId, ACEM_SYNC_BASE_LINE_NAME) < 0) {
                continue;
            }
            baseTime = (datetime)ObjectGetInteger(targetId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);

            datetime currentTime = (datetime)ObjectGetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
            int currentIndex = convTimeToIndex(chartId, currentTime);
            int shift = m_baseIndex - currentIndex;
            // m_baseXPos = convTimeToPosX(chartId, currentTime);
            ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
            ChartNavigate(chartId, CHART_CURRENT_POS, shift);
            ChartRedraw(chartId);

            break;
        }
    } else {
        baseTime = (datetime)ObjectGetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    }
    // 初期化処理
    m_period = ChartPeriod(chartId);

    ObjectSetInteger(ChartID(), ACEM_CHART_HIDE_CANVAS, OBJPROP_SELECTABLE, false);

    setBaseLineProp();
}

void CAcemSyncChartPos::deinit(const int reason)
{
    debugPrint("void CAcemSyncChartPos::deinit(const int reason)");

    if (reason != REASON_INITFAILED) {
        outputParm();
    }

    switch (reason) {
        case REASON_REMOVE:
            {
                ObjectDelete(ChartID(), ACEM_SYNC_BASE_LINE_NAME);
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
}

bool CAcemSyncChartPos::OnObjectChange(int id, long lparam, double dparam, string sparam)
{
    debugPrint("void CAcemSyncChartPos::OnObjectChange(int id, long lparam, double dparam, string sparam)");

    if (sparam == ACEM_SYNC_BASE_LINE_NAME) {
        long chartId = ChartID();
        if (ChartGetInteger(chartId, CHART_BRING_TO_TOP)) {
            shiftBaseIndexToBasePos(chartId);
        }
    }
    return true;
}

bool CAcemSyncChartPos::OnObjectDelete(int id, long lparam, double dparam, string sparam)
{
    debugPrint("void CAcemSyncChartPos::OnObjectDelete(int id, long lparam, double dparam, string sparam)");
    debugPrint(sparam);

    if (sparam == ACEM_CHART_HIDE_CANVAS) {
        debugPrint("Delete:" + ACEM_CHART_HIDE_CANVAS);
    }

    if (sparam == ACEM_SYNC_BASE_LINE_NAME) {
        long chartId = ChartID();
        ObjectCreate(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJ_VLINE, 0, m_baseTime, 0, 0);
        setBaseLineProp();
    }
    return true;
}

bool CAcemSyncChartPos::OnObjectDrag(int id, long lparam, double dparam, string sparam)
{
    debugPrint("void CAcemSyncChartPos::OnObjectDrag(int id, long lparam, double dparam, string sparam)");

    if (sparam == ACEM_SYNC_BASE_LINE_NAME) {
        if (ChartGetInteger(ChartID(), CHART_BRING_TO_TOP)) {
            shiftChartToBaseLine();
            setOffsetRatio();
        }
    }
    return true;
}

bool CAcemSyncChartPos::OnChartChange(int id, long lparam, double dparam, string sparam)
{
    debugPrint("void CAcemSyncChartPos::OnChartChange(int id, long lparam, double dparam, string sparam)");

    if (m_chartBarNum != WindowBarsPerChart()) {
        m_chartBarNum = WindowBarsPerChart();
        int baseOffset = (int)MathRound(WindowBarsPerChart() * m_baseOffsetRatio);
        int leftIndex = WindowFirstVisibleBar();
        int shift = (leftIndex - m_baseIndex) - baseOffset;
        m_baseXPos = convIndexToPosX(ChartID(), leftIndex - baseOffset);
        ChartNavigate(ChartID(), CHART_CURRENT_POS, -shift);
    } else {
        if (ChartGetInteger(ChartID(), CHART_BRING_TO_TOP)) {
            moveBaseLineToBasePos(ChartID());
            syncOtherChart();
        } else {
            moveBaseLineToBasePos(ChartID());
        }
    }

    ChartRedraw(ChartID());
    return true;
}

bool CAcemSyncChartPos::OnCustomEvent(int id, long lparam, double dparam, string sparam)
{
    debugPrint("void CAcemSyncChartPos::OnCustomEvent(int id, long lparam, double dparam, string sparam)");

    if ("AcemChartSync" == sparam) {
        m_baseTime = (datetime)ObjectGetInteger(ChartID(), ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
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
    debugPrint("void CAcemSyncChartPos::shiftChartToBaseLine()");

    long chartId = ChartID();
    datetime currentTime = (datetime)ObjectGetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    int currentIndex = convTimeToIndex(chartId, currentTime);
    int shift = m_baseIndex - currentIndex;
    m_baseXPos = convTimeToPosX(chartId, currentTime);

    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
    ChartNavigate(chartId, CHART_CURRENT_POS, -shift);
    ChartRedraw(chartId);
}

void CAcemSyncChartPos::shiftChartToBaseLineOtherChart(long chartId, datetime currentTime)
{
    debugPrint("void CAcemSyncChartPos::shiftChartToBaseLineOtherChart(long chartId, datetime currentTime)");

    datetime baseTime = (datetime)ObjectGetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME);
    int baseIndex = convTimeToIndex(chartId, baseTime);
    int shift = baseIndex - convTimeToIndex(chartId, currentTime);
    ChartNavigate(chartId, CHART_CURRENT_POS, shift);
    ChartRedraw(chartId);
}

void CAcemSyncChartPos::shiftBaseIndexToBasePos(long chartId)
{
    debugPrint("void CAcemSyncChartPos::shiftBaseIndexToBasePos(shiftBaseIndexToBasePos)");

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
    debugPrint("void CAcemSyncChartPos::moveBaseLineToBasePos(long chartId)");

    m_baseTime = convPosXToTime(chartId, m_baseXPos);
    m_baseIndex = convPosXToIndex(chartId, m_baseXPos);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_TIME, m_baseTime);
    ChartRedraw(chartId);
}

int CAcemSyncChartPos::getOffsetIndex(int offset)
{
    debugPrint("void CAcemSyncChartPos::getOffsetIndex(int offset)");

    int leftIndex = WindowFirstVisibleBar();
    int offsetIndex = leftIndex - offset;

    return offsetIndex;
}

void CAcemSyncChartPos::syncOtherChart()
{
    debugPrint("void CAcemSyncChartPos::syncOtherChart()");

    // Print(ChartID()+" : " + m_baseIndex);
    long targetId;
    for (targetId = ChartFirst(); targetId != -1; targetId = ChartNext(targetId)) {
        if (targetId == ChartID()) {
            continue;
        }

        if (ChartSymbol(ChartID()) != ChartSymbol(targetId)) {
            continue;
        }

        // 基準線がないのは対象外
        if (ObjectFind(targetId, ACEM_SYNC_BASE_LINE_NAME) < 0) {
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
    debugPrint("void CAcemSyncChartPos::setOffsetRatio()");

    int width = WindowBarsPerChart();
    int leftIndex = WindowFirstVisibleBar();
    int indexPos = leftIndex - m_baseIndex;
    m_baseOffsetRatio = (double)indexPos / (double)width;
    GlobalVariableSet(m_strGlobalBaseOffsetRatio, m_baseOffsetRatio);
}

void CAcemSyncChartPos::outputParm()
{
    debugPrint("void CAcemSyncChartPos::outputParm()");

    GlobalVariableSet(m_strGlobalBaseOffsetRatio, m_baseOffsetRatio);
}

void CAcemSyncChartPos::deleteParm()
{
    debugPrint("void CAcemSyncChartPos::deleteParm()");

    GlobalVariableDel(m_strGlobalBaseOffsetRatio);
}

void CAcemSyncChartPos::setBaseLineProp()
{
    debugPrint("void CAcemSyncChartPos::setBaseLineProp()");

    long chartId = ChartID();
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_READONLY, false);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_HIDDEN, false);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_COLOR, ACEM_SYNC_POS_BASE_LINE_COLOR);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_STYLE, ACEM_SYNC_POS_BASE_LINE);
    ObjectSetInteger(chartId, ACEM_SYNC_BASE_LINE_NAME, OBJPROP_WIDTH, ACEM_SYNC_POS_BASE_LINE_WIDTH);
    ChartRedraw(chartId);
}
