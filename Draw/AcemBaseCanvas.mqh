//+------------------------------------------------------------------+
//|                                                 AcemBaseCanvas.mqh |
//|                                             Copyright 2023, Acem |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <Acem/Common/AcemDebug.mqh>
#include <Canvas/Canvas.mqh>

class CAcemBaseCanvas : public CCanvas
{
protected:
    CAcemBaseCanvas(){}; //  使用禁止
    string m_canvasName;

public:
    CAcemBaseCanvas(string canvasName);
    ~CAcemBaseCanvas();

    virtual bool init() = 0;
    virtual bool init(int x, int y, int width, int height);
    bool deinit(const int reason);
/*
    // #ifdef __MQL4__
    virtual bool Attach(const long chart_id, const string objname, ENUM_COLOR_FORMAT clrfmt = COLOR_FORMAT_XRGB_NOALPHA);
    // #endif
*/
    bool Attach();
    bool resize(int width, int height, bool bUpdate);
    void move(int x, int y);
    void fill(uint argbColor);
    void clearParam();
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
        if (!Attach()) {
            return false;
        }
    } else if (!CreateBitmapLabel(m_canvasName, x, y, width, height, COLOR_FORMAT_ARGB_NORMALIZE)) {
        return false;
    }
    ObjectSetInteger(0, m_canvasName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, m_canvasName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, m_canvasName, OBJPROP_BACK, false);

    return true;
}

bool CAcemBaseCanvas::deinit(const int reason)
{
    switch (reason) {
        case REASON_REMOVE:
            {
                Destroy();
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
    return true;
}

bool CAcemBaseCanvas::Attach()
{
debugPrint(__FUNCTION__ + " Start");
    long chart_id = ChartID();
    ENUM_COLOR_FORMAT clrfmt = COLOR_FORMAT_ARGB_NORMALIZE;
    int width = (int)ObjectGetInteger(chart_id, m_canvasName, OBJPROP_XSIZE);
    if (width <= 0) {
        width = 1;
    }
    int height = (int)ObjectGetInteger(chart_id, m_canvasName, OBJPROP_YSIZE);
    if (height <= 0) {
        height = 1;
    }
    
    string rcname = ObjectGetString(chart_id, m_canvasName, OBJPROP_BMPFILE);
    rcname=StringSubstr(rcname,StringFind(rcname,"::"));
    if(ResourceReadImage(rcname,m_pixels,m_width,m_height)) {
debugPrint(__FUNCTION__ + " ResourceReadImage");
         m_chart_id=chart_id;
         m_objname=m_canvasName;
         m_rcname=rcname;
         m_format=clrfmt;
         m_objtype=OBJ_BITMAP_LABEL;
         //--- success
         return true;
    } else {
        if (OBJ_BITMAP_LABEL == ObjectGetInteger(chart_id, m_canvasName, OBJPROP_TYPE)) {
debugPrint(__FUNCTION__ + " ResourceCreate");
            if (width > 0 && height > 0 && ArrayResize(m_pixels, width * height) > 0) {
                ZeroMemory(m_pixels);
                if (ResourceCreate(rcname, m_pixels, width, height, 0, 0, 0, clrfmt) &&
                    ObjectSetString(chart_id, m_canvasName, OBJPROP_BMPFILE, rcname)) {
                    m_chart_id = chart_id;
                    m_width = width;
                    m_height = height;
                    m_objname = m_canvasName;
                    m_rcname = rcname;
                    m_format = clrfmt;
                    m_objtype = OBJ_BITMAP_LABEL;
                    //--- success
debugPrint(__FUNCTION__ + " End Success");
                    return true;
                }
            }
        }
    }

debugPrint(__FUNCTION__ + " End Failed");
    return false;
}

bool CAcemBaseCanvas::resize(int width, int height, bool bUpdate)
{
    if (m_width != width || m_height != height) {
        if (!Resize((int)width, (int)height)) {
            return false;
        }
        if (bUpdate) {
            Update();
        }
    }
    
    return true;
}

void CAcemBaseCanvas::move(int x, int y)
{
    if (ObjectFind(ChartID(), m_canvasName) >= 0) {
        ObjectSetInteger(ChartID(), m_canvasName, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(ChartID(), m_canvasName, OBJPROP_YDISTANCE, y);
    }
}

void CAcemBaseCanvas::fill(uint argbColor)
{
debugPrint(__FUNCTION__ + " Start");
    Fill(0, 0, argbColor);
debugPrint(__FUNCTION__ + " End");
}

void CAcemBaseCanvas::clearParam()
{
    m_width = 0;
    m_height = 0;
}