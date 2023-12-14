/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "ArduRoverFirmwarePlugin.h"
#include "QGCApplication.h"

bool ArduRoverFirmwarePlugin::_remapParamNameIntialized = false;
FirmwarePlugin::remapParamNameMajorVersionMap_t ArduRoverFirmwarePlugin::_remapParamName;

APMRoverMode::APMRoverMode(uint32_t mode, bool settable)
    : APMCustomMode(mode, settable)
{
    setEnumToStringMapping({
        {MANUAL,         "Manual"},
        {ACRO,           "Acro"},
        {STEERING,       "Steering"},
        {HOLD,           "Hold"},
        {LOITER,         "Loiter"},
        {FOLLOW,         "Follow"},
        {SIMPLE,         "Simple"},
        {AUTO,           "Auto"},
        {RTL,            "RTL"},
        {SMART_RTL,      "Smart RTL"},
        {GUIDED,         "Guided"},
        {INITIALIZING,   "Initializing"},
    });
}

ArduRoverFirmwarePlugin::ArduRoverFirmwarePlugin(void)
{
    setSupportedModes({
        APMRoverMode(APMRoverMode::MANUAL       ,true),
        APMRoverMode(APMRoverMode::ACRO         ,false),
        APMRoverMode(APMRoverMode::STEERING     ,false),
        APMRoverMode(APMRoverMode::HOLD         ,false),
        APMRoverMode(APMRoverMode::LOITER       ,true),
        APMRoverMode(APMRoverMode::FOLLOW       ,true),
        APMRoverMode(APMRoverMode::SIMPLE       ,false),
        APMRoverMode(APMRoverMode::AUTO         ,true),
        APMRoverMode(APMRoverMode::RTL          ,false),
        APMRoverMode(APMRoverMode::SMART_RTL    ,false),
        APMRoverMode(APMRoverMode::GUIDED       ,false),
        APMRoverMode(APMRoverMode::INITIALIZING ,false),
    });

    if (!_remapParamNameIntialized) {
        FirmwarePlugin::remapParamNameMap_t& remapV3_5 = _remapParamName[3][5];

        remapV3_5["BATT_ARM_VOLT"] =    QStringLiteral("ARMING_VOLT_MIN");
        remapV3_5["BATT2_ARM_VOLT"] =   QStringLiteral("ARMING_VOLT2_MIN");

        _remapParamNameIntialized = true;
    }
}

int ArduRoverFirmwarePlugin::remapParamNameHigestMinorVersionNumber(int majorVersionNumber) const
{
    // Remapping supports up to 3.5
    return majorVersionNumber == 3 ? 5 : Vehicle::versionNotSetValue;
}

void ArduRoverFirmwarePlugin::guidedModeChangeAltitude(Vehicle* /*vehicle*/, double /*altitudeChange*/, bool /*pauseVehicle*/)
{
    qgcApp()->showAppMessage(QStringLiteral("Change altitude not supported."));
}

bool ArduRoverFirmwarePlugin::supportsNegativeThrust(Vehicle* /*vehicle*/)
{
    return true;
}

void ArduRoverFirmwarePlugin::sendGCSMotionReport(Vehicle* vehicle, FollowMe::GCSMotionReport& motionReport, uint8_t estimatationCapabilities)
{
    _sendGCSMotionReport(vehicle, motionReport, estimatationCapabilities);
}

