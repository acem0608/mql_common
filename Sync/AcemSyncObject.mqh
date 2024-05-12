//+------------------------------------------------------------------+
//|                                               AcemSyncObject.mqh |
//|                                         Copyright 2023, Acem0608 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Acem0608"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Acem/Common/AcemBase.mqh>
#include <Acem/Common/AcemDefine.mqh>
#include <Acem/Common/AcemDebug.mqh>

class CAcemSyncObject : public CAcemBase
{
protected:
    CAcemSyncObject(){};

    string m_strIndiName;
//    ushort m_eventId;
//    string m_dragNewObjName;
    
    virtual bool OnObjectCreate(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectChange(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectDrag(int id, long lparam, double dparam, string sparam);
    virtual bool OnObjectDelete(int id, long lparam, double dparam, string sparam);
    virtual bool OnCustomEvent(int id, long lparam, double dparam, string sparam);

//    void cloneObject(string objName, long fromChartId, long toChartId);
//    void setSameProp(string objName, long fromChartId, long toChartId);
    void syncChartObject(string objName);
    void syncChartObject(string objName, long fromChartId, long toChartId);
    bool isSyncObject(string objName);

public:
    CAcemSyncObject(string indiDname);
    ~CAcemSyncObject();
    void init();
    void deinit(const int reason);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemSyncObject::CAcemSyncObject(string indiDname)
{
    m_strIndiName = indiDname;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAcemSyncObject::~CAcemSyncObject()
{
}
//+------------------------------------------------------------------+
void CAcemSyncObject::init()
{
}

void CAcemSyncObject::deinit(const int reason)
{
}

bool CAcemSyncObject::OnObjectCreate(int id, long lparam, double dparam, string sparam)
{
debugPrint("CAcemSyncObject::OnObjectCreate():" + sparam);

    syncChartObject(sparam);

    return true;
}

bool CAcemSyncObject::OnObjectDrag(int id, long lparam, double dparam, string sparam)
{
debugPrint("CAcemSyncObject::OnObjectDrag()");

    syncChartObject(sparam);

    return true;
}

bool CAcemSyncObject::OnObjectChange(int id, long lparam, double dparam, string sparam)
{
debugPrint("CAcemSyncObject::OnObjectChange()");

    syncChartObject(sparam);

    return true;
}

bool CAcemSyncObject::OnObjectDelete(int id, long lparam, double dparam, string sparam)
{
debugPrint(__FUNCTION__ + " sparam: " + sparam);
    if (!ChartGetInteger(ChartID(), CHART_BRING_TO_TOP)) {
        return true;
    }

    if (!isSyncObject(sparam)) {
        return true;
    }

    long fromChartId = ChartID();
    long toChartId;
    for (toChartId = ChartFirst();toChartId != -1; toChartId = ChartNext(toChartId)) {
        if (toChartId == fromChartId) {
           continue;
        }

        if (ChartSymbol(ChartID()) != ChartSymbol(toChartId)) {
           continue;
        }
        ObjectDelete(toChartId, sparam);
        ChartRedraw(toChartId);
    }

    return true;
}

bool CAcemSyncObject::isSyncObject(string objName)
{
debugPrint("CAcemSyncObject::isSyncObject()");
    if (StringFind(objName, ACEM_IDENTIFER + " " + ACEM_SYNC_KEYWORD) < 0) {
        return false;
    }

    if (StringFind(objName, ACEM_FREECURVE_DATA_PREFIX) == 0) {
        return false;
    }
    
    ENUM_OBJECT objType = (ENUM_OBJECT)ObjectGetInteger(ChartID(), objName, OBJPROP_TYPE);
    switch (objType) {
        case OBJ_VLINE:
        case OBJ_HLINE:
        case OBJ_RECTANGLE:
        case OBJ_TREND:
        case OBJ_CHANNEL:
            break;
        default:
            return false;
            break;
    }
    return true;
}

void CAcemSyncObject::syncChartObject(string objName)
{
    long fromChartId = ChartID();
    long toChartId;
    for (toChartId = ChartFirst();toChartId != -1; toChartId = ChartNext(toChartId)) {
        syncChartObject(objName, fromChartId, toChartId);
   }
}

void CAcemSyncObject::syncChartObject(string objName, long fromChartId, long toChartId)
{
debugPrint("CAcemSyncObject::syncChartObject()");

    if (!isSyncObject(objName)) {
        return;
    }

    if (toChartId == fromChartId) {
       return;
    }
    
    if (ChartSymbol(ChartID()) != ChartSymbol(toChartId)) {
       return;
    }
    
    string strIndiName;
    int i;
    int indiNum = ChartIndicatorsTotal(toChartId, 0);
    for (i = 0; i < indiNum; i++) {
        strIndiName = ChartIndicatorName(toChartId, 0, i);
        if (strIndiName == m_strIndiName) {
            if (ObjectFind(toChartId, objName) < 0) {
                cloneObject(fromChartId, objName, toChartId, objName);
            }
            setSameProp(fromChartId, objName, toChartId, objName);
            ChartRedraw(toChartId);
            break;
        }
    }
}

bool CAcemSyncObject::OnCustomEvent(int id, long lparam, double dparam, string sparam)
{
debugPrint("CAcemSyncObject::OnCustomEvent()");
    int eventId = id - CHARTEVENT_CUSTOM;
    if (eventId == CHARTEVENT_OBJECT_CHANGE) {
        OnObjectChange(eventId, lparam, dparam, sparam);
    }

    return true;
}