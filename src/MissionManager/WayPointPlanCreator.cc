/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "WayPointPlanCreator.h"
#include "PlanMasterController.h"
#include "MissionSettingsItem.h"
#include "CorridorScanComplexItem.h"

WayPointPlanCreator::WayPointPlanCreator(PlanMasterController* planMasterController, QObject* parent)
    : PlanCreator(planMasterController, CorridorScanComplexItem::name, QStringLiteral("/qmlimages/PlanCreator/CorridorScanPlanCreator.png"), parent)
{

}

void WayPointPlanCreator::createPlan(const QGeoCoordinate& mapCenterCoord)
{
    _planMasterController->removeAll();
    VisualMissionItem* takeoffItem = _missionController->insertTakeoffItem(mapCenterCoord, -1);
    takeoffItem->setWizardMode(false);
    _missionController->insertLandItem(mapCenterCoord, -1);
    _missionController->setCurrentPlanViewSeqNum(takeoffItem->sequenceNumber(), true);
}
