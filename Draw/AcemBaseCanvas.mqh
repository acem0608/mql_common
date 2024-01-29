//+------------------------------------------------------------------+
//|                                                 AcemBaseCanvas.mqh |
//|                                             Copyright 2023, Acem |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Canvas/Canvas.mqh>

class CAcemBaseCanvas : public CCanvas
{
protected:
    CAcemBaseCanvas() {};   //  使用禁止
    string m_canvasName;

public:
    CAcemBaseCanvas(string canvasName);
    ~CAcemBaseCanvas();
    
    virtual bool init() = 0;
    virtual bool init(int x, int y, int width, int height);
    bool deinit();
    void resize(int width, int height);
    void move(int x, int y);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemBaseCanvas::CAcemBaseCanvas(string canvasName)
{
    m_canvasName = canvasName;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemBaseCanvas::~CAcemBaseCanvas()
{
}
//+------------------------------------------------------------------+

bool CAcemBaseCanvas::init(int x, int y, int width, int height)
{
    int objIndex = ObjectFind(ChartID(), m_canvasName);
    if (objIndex >= 0 && ObjectGetInteger(ChartID(), m_canvasName, OBJPROP_TYPE) == OBJ_BITMAP_LABEL) {
        ObjectDelete(0, m_canvasName);
    }

    if (!CreateBitmapLabel(m_canvasName, x, y, width, height, COLOR_FORMAT_ARGB_NORMALIZE))
    {
        return (false);
    }
    ObjectSetInteger(0, m_canvasName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, m_canvasName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, m_canvasName, OBJPROP_BACK, false);
    ObjectSetInteger(ChartID(), m_canvasName, OBJPROP_ZORDER, 1);

    return true;
}

bool CAcemBaseCanvas::deinit()
{
    Erase(0x00000000);
    Update();
    ObjectDelete(ChartID(), m_canvasName);

    return true;
}

void CAcemBaseCanvas::resize(int width, int height)
{
    if (m_width != width || m_height != height)
    {
        m_width = width;
        m_height = height;
        Resize((int)m_width, (int)m_height);
        Erase(ColorToARGB(0xff000000));
        Update();
    }
}

void CAcemBaseCanvas::move(int x, int y)
{
    if (ObjectFind(ChartID(), m_canvasName) >= 0)
    {
        ObjectSetInteger(ChartID(), m_canvasName, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(ChartID(), m_canvasName, OBJPROP_YDISTANCE, y);
    }
}