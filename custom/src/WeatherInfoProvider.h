/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QObject>
#include <QDateTime>

class QNetworkAccessManager;
class QNetworkReply;

class WeatherInfoProvider : public QObject
{
	Q_OBJECT

    struct LocationData
    {
        QString step1;
        QString step2;
        QString step3;
        double x;
        double y;
        double longitude;
        double latitude;
    };

    struct WeatherData
    {
        LocationData location;
        QDateTime time;
        QString t1h;
        QString rn1;
        QString sky;
        QString uuu;
        QString vvv;
        QString reh;
        QString pty;
        QString lgt;
        QString vec;
        QString wsd;
    };

    struct WeatherUiData
    {
        QString location;
        QDateTime time;
        int sky; // sky status 1: clear 2: cloudy 4: blur
        int wind; // wind speed m/s
        int temperature; // celsius
        int rain; // 1hour rain

        WeatherUiData(void) : sky(0), wind(0), temperature(0), rain(0) {}
    };

private:
    QNetworkAccessManager* _networkAccessManager;
    WeatherUiData _weatherUiData;
    bool _isValid;

public:
    WeatherInfoProvider(QObject* parent = nullptr);
    ~WeatherInfoProvider(void);

    Q_PROPERTY(QString location READ getLocation NOTIFY notifyWeatherData)
    Q_PROPERTY(int sky READ getSky NOTIFY notifyWeatherData)
    Q_PROPERTY(int wind READ getWind NOTIFY notifyWeatherData)
    Q_PROPERTY(int temperature READ getTemperature NOTIFY notifyWeatherData)
    Q_PROPERTY(int rain READ getRain NOTIFY notifyWeatherData)
    Q_PROPERTY(bool valid READ isValid NOTIFY notifyWeatherData)

    Q_INVOKABLE void requestWeatherData(double longitude, double latitude);

    QString getLocation(void) const { return _weatherUiData.location; }
    int getSky(void) const { return _weatherUiData.sky; }
    int getWind(void) const { return _weatherUiData.wind; }
    int getTemperature(void) const { return _weatherUiData.temperature; }
    int getRain(void) const { return _weatherUiData.rain; }
    bool isValid(void) const { return _isValid; }

private:
    void parseWeatherJson(const QByteArray& jsonData);
    static bool findRegionName(double longitude, double latitude, LocationData& outData);
    static QString getWeatherApiKey(void);

signals:
    void notifyWeatherData(void);

private slots:
    void onNetworkReply(QNetworkReply* reply);
};
