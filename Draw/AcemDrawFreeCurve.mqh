//+------------------------------------------------------------------+
//|                                            AcemDrawFreeCurve.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Arrays/List.mqh>
#include <Acem/Common/AcemBase.mqh>
#include <Acem/Common/AcemDefine.mqh>
#include <Acem/Draw/AcemFreeCurveData.mqh>
#include <Acem/Draw/AcemFreeCurveCanvas.mqh>

input color ACEM_DRAW_FREE_CURVE_LINE_COLOR = 0x00FFFFFF;        // 　　色
input int ACEM_DRAW_RFRE_CURVE_LINE_WIDTH = 1;                 // 　　線幅
class CAcemDrawFreeCurve : public CAcemBase
{
private:
    CList m_listLine;
    CAcemFreeCurveData *m_pCurrentLine;
    CAcemFreeCurveCanvas m_canvas;
    
    color m_lineColor;
    int m_lineWidth;

public:
    CAcemDrawFreeCurve();
    ~CAcemDrawFreeCurve();

    bool init();
    virtual bool OnMouseMove(int id, long lparam, double dparam, string sparam);
    virtual bool OnChartChange(int id, long lparam, double dparam, string sparam);

    bool convWindowsPosToChartPos(int id, int x, int y, datetime &time, double &price);
    bool convChartPosToWindowsPos(int id, datetime time, double price, int &x, int &y);
    
    bool drawLine(CAcemChartPoint* pStPoint, CAcemChartPoint* pEdPoint, int lineWidth, color lineColor);
    bool redraw();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemDrawFreeCurve::CAcemDrawFreeCurve() : m_canvas(ACEM_FREE_CUREVE_CANVAS_NAME), m_pCurrentLine(NULL)
{
    m_listLine.FreeMode(true);
    m_lineColor = ACEM_DRAW_FREE_CURVE_LINE_COLOR;
    m_lineWidth = ACEM_DRAW_RFRE_CURVE_LINE_WIDTH;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemDrawFreeCurve::~CAcemDrawFreeCurve()
{
}
//+------------------------------------------------------------------+

bool CAcemDrawFreeCurve::init()
{
    m_canvas.init();
    m_pCurrentLine = NULL;
    m_listLine.Clear();

    return true;
}

bool CAcemDrawFreeCurve::OnMouseMove(int id, long lparam, double dparam, string sparam)
{
    uint flag = (uint)sparam;
    if ((flag & 0x08) == 0x08)
    {

        int x = (int)lparam;
        int y = (int)dparam;
        datetime time;
        double price;

        convWindowsPosToChartPos(ChartID(), x, y, time, price);

        CAcemChartPoint *pChartPoint = new CAcemChartPoint(time, price);
        CAcemChartPoint *pLastPoint = NULL;

        if (m_pCurrentLine == NULL)
        {
            m_pCurrentLine = new CAcemFreeCurveData();
            m_pCurrentLine.setColor(m_lineColor);
            m_pCurrentLine.setLineWidth(m_lineWidth);
            if (m_pCurrentLine == NULL)
            {
                return false;
            }
            m_listLine.Add(m_pCurrentLine);
        }
        else
        {
            pLastPoint = m_pCurrentLine.GetLastNode();
        }
        m_pCurrentLine.Add(pChartPoint);

        if (pLastPoint != NULL)
        {
            int lineWidth = m_pCurrentLine.getLineWidth();
            color lineColor = m_pCurrentLine.getLineColor();
            drawLine(pLastPoint, pChartPoint, lineWidth, lineColor);
        }
    }
    else
    {
        if (m_pCurrentLine != NULL)
        {
            m_pCurrentLine = NULL;
        }
    }

    return true;
}

bool CAcemDrawFreeCurve::OnChartChange(int id, long lparam, double dparam, string sparam)
{
    redraw();

    return true;
}

bool CAcemDrawFreeCurve::convWindowsPosToChartPos(int id, int x, int y, datetime &time, double &price)
{
    int subWindow = 0;
    ChartXYToTimePrice(ChartID(), x, y, subWindow, time, price);

    int leftIndex = WindowFirstVisibleBar();
    datetime leftTime = Time[leftIndex];
    int chartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
    int step = int(1 << chartScale);
    int stepNum = int(x / step);
    int chartPeriod = (int)ChartPeriod(ChartID());
    int mod = x - (stepNum * step);
    int modTime = int(mod * 60 * chartPeriod / step);
    datetime convTime = leftTime + (chartPeriod * stepNum * 60) + modTime;

    time = convTime;

    return true;
}

bool CAcemDrawFreeCurve::convChartPosToWindowsPos(int id, datetime time, double price, int &x, int &y)
{
    int subWindow = 0;
    ChartTimePriceToXY(ChartID(), subWindow, time, price, x, y);

    int leftIndex = WindowFirstVisibleBar();
    datetime leftTime = Time[leftIndex];
    int chartScale = (int)ChartGetInteger(ChartID(), CHART_SCALE);
    int step = int(1 << chartScale);
    int chartPeriod = (int)ChartPeriod(ChartID());
    uint timeStep = chartPeriod * 60;
    long diffTime = time - leftTime;
    if (diffTime < 0)
    {
        return false;
    }
    double stepNum = (double)(diffTime / (double)timeStep);
    int convX = (int)MathRound(stepNum * step);
    // Print("conv : time = " + TimeToStr(time) + " : x = " + IntegerToString(x) + " : conX = "+ IntegerToString(convX));
    x = convX;

    return true;
}

bool CAcemDrawFreeCurve::drawLine(CAcemChartPoint* pStPoint, CAcemChartPoint* pEdPoint, int lineWidth, color lineColor)
{
    int x1;
    int y1;
    int x2;
    int y2;
    double stPrice;
    datetime stTime;
    double edPrice;
    datetime edTime;

    pStPoint.getTimePrice(stTime, stPrice);
    pEdPoint.getTimePrice(edTime, edPrice);
    convChartPosToWindowsPos(ChartID(), stTime, stPrice, x1, y1);
    convChartPosToWindowsPos(ChartID(), edTime, edPrice, x2, y2);

    m_canvas.drawLine(x1, y1, x2, y2, lineWidth, lineColor);

    return true;
}

bool CAcemDrawFreeCurve::redraw(void)
{
    m_canvas.Erase();
    
    CAcemFreeCurveData* pCurveData;
    int lineWidth;
    color lineColor;

    for (pCurveData = m_listLine.GetFirstNode(); pCurveData != NULL; pCurveData = m_listLine.GetNextNode()) {
        if (pCurveData.Total() < 2) {
            continue;
        }
        lineWidth = pCurveData.getLineWidth();
        lineColor = pCurveData.getLineColor();
        CAcemChartPoint* pStPoint = pCurveData.GetFirstNode();
        CAcemChartPoint* pEdPoint;
        for (pEdPoint = pCurveData.GetNextNode(); pEdPoint != NULL; pEdPoint = pCurveData.GetNextNode()) {
            drawLine(pStPoint, pEdPoint, lineWidth, lineColor);
            pStPoint = pEdPoint;
        }
    }
    
    return true;
}