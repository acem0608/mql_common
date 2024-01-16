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
private:
    CAcemBaseCanvas() {};   //  使用禁止

protected:
    string m_canvasName;

public:
    CAcemBaseCanvas(string canvasName);
    ~CAcemBaseCanvas();
    
    bool init();
    bool deinit();
    void Resize();
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

bool CAcemBaseCanvas::init()
{
    m_width = (int)ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS);
    m_height = (int)ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS);

    int objIndex = ObjectFind(ChartID(), m_canvasName);
    if (objIndex >= 0 && ObjectGetInteger(ChartID(), m_canvasName, OBJPROP_TYPE) == OBJ_BITMAP_LABEL) {
        ObjectDelete(0, m_canvasName);
    }

    if (!CreateBitmapLabel(m_canvasName, 0, 0, (int)m_width, (int)m_height, COLOR_FORMAT_ARGB_NORMALIZE))
    {
        return (false);
    }
    ObjectSetInteger(0, m_canvasName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, m_canvasName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, m_canvasName, OBJPROP_BACK, false);
    ObjectSetInteger(ChartID(), m_canvasName, OBJPROP_ZORDER, 1);
    Resize();

    return true;
}

bool CAcemBaseCanvas::deinit()
{
    Destroy();
    return true;
}

void CAcemBaseCanvas::Resize()
{
    int width = (int)ChartGetInteger(ChartID(), CHART_WIDTH_IN_PIXELS);
    int height = (int)ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS);

    if (m_width != width || m_height != m_height)
    {
        m_width = width;
        m_height = height;
        Resize((int)m_width, (int)m_height);
        Erase(ColorToARGB(0xff000000));
        Update();
    }
}
