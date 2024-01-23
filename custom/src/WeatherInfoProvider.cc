/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "WeatherInfoProvider.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QJsonValue>
#include <cmath>

WeatherInfoProvider::WeatherInfoProvider(QObject* parent)
: QObject(parent), _networkAccessManager(nullptr), _isValid(false)
{
}

WeatherInfoProvider::~WeatherInfoProvider(void)
{
}

void WeatherInfoProvider::requestWeatherData(double longitude, double latitude)
{
    qDebug() << "WeatherInfoProvider::requestWeatherData";

    LocationData locationData;
    findRegionName(longitude, latitude, locationData);

    _weatherUiData.location = locationData.step1;
    if (locationData.step2.isNull() == false && locationData.step2.isEmpty() == false) {
        _weatherUiData.location.append(" ").append(locationData.step2);
        if (locationData.step3.isNull() == false && locationData.step3.isEmpty() == false) {
            _weatherUiData.location.append(" ").append(locationData.step3);
        }
    }

    QString numOfRows = "60";
    QString nx = QString::number(locationData.x);
    QString ny = QString::number(locationData.y);
    QString baseDate = QDateTime::currentDateTime().toString("yyyyMMdd");

    QTime currentTime = QDateTime::currentDateTime().time();
    int hour = currentTime.hour();
    int minute = currentTime.minute();
    if (minute < 40) {
        hour -= 1;
        if (hour < 0) {
            hour = 23;
        }
    }
    QString baseTime = QString::number(hour).rightJustified(2, '0').append("00");
    QString type = "JSON";


    QString apiUrl = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst";
    QString apiKey = getWeatherApiKey();

    QString requestUrl = apiUrl + "?serviceKey=" + apiKey +
                            "&numOfRows=" + numOfRows +
                            "&nx=" + nx +
                            "&ny=" + ny +
                            "&base_date=" + baseDate +
                            "&base_time=" + baseTime +
                            "&dataType=" + type;

    if (_networkAccessManager == nullptr) {
        _networkAccessManager = new QNetworkAccessManager(this);
        connect(_networkAccessManager, &QNetworkAccessManager::finished, this, &WeatherInfoProvider::onNetworkReply);
    }

    QNetworkRequest request;
    request.setUrl(QUrl(requestUrl));
    _networkAccessManager->get(request);
}

void WeatherInfoProvider::onNetworkReply(QNetworkReply* reply)
{
    qDebug() << "WeatherInfoProvider::onNetworkReply";

    qDebug() << "Response Code:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    QByteArray responseData = reply->readAll();
    //qDebug() << "Response Data:" << responseData;

    QJsonParseError jsonError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(responseData, &jsonError);
    if (jsonError.error == QJsonParseError::NoError && jsonDocument.isObject()) {
        qDebug() << "Response Data is JSON";

        parseWeatherJson(responseData);
    } else {
        qDebug() << "Response Data is XML";
    }

    reply->deleteLater();
}

void WeatherInfoProvider::parseWeatherJson(const QByteArray& jsonData)
{
    QJsonParseError jsonError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &jsonError);

    if (jsonError.error != QJsonParseError::NoError) {
        qDebug() << "JSON parsing error:" << jsonError.errorString();
        return;
    }

    // extract top level object
    QJsonObject jsonObject = jsonDoc.object();

    // extract value of 'response' key
    QJsonObject responseObj = jsonObject.value("response").toObject();

    // extract value of 'body' key
    QJsonObject bodyObj = responseObj.value("body").toObject();

    // extract value of 'items' key
    QJsonObject itemsObj = bodyObj.value("items").toObject();

    // extract value of 'item' key
    QJsonArray itemArray = itemsObj.value("item").toArray();

    QDateTime earlistTime;
    WeatherData wd;

    // process each item
    for (int i = 0; i < itemArray.size(); ++i) {
        QJsonObject itemObj = itemArray.at(i).toObject();

        //qDebug() << itemObj;

        QString baseDate = itemObj.value("baseDate").toString();
        QString baseTime = itemObj.value("baseTime").toString();
        QString category = itemObj.value("category").toString();
        QString fcstDate = itemObj.value("fcstDate").toString();
        QString fcstTime = itemObj.value("fcstTime").toString();
        QString fcstValue = itemObj.value("fcstValue").toString();
/*
        qDebug() << "baseDate:" << baseDate
            << "baseTime:" << baseTime
            << "category:" << category
            << "fctsDate:" << fcstDate
            << "fctsTime:" << fcstTime
            << "fcstValue:" << fcstValue;
*/
        QDateTime dt = QDateTime::fromString(QString("%1%2").arg(fcstDate).arg(fcstTime), QString("yyyyMMddhhmm"));
        //qDebug() << "dt: " << dt.toString("yyMMddhhmm");

        if (wd.time.isNull() || dt < wd.time) {
            wd.time = dt;
        }
        if (dt == wd.time) {
            if (category == "T1H") {
                wd.t1h = fcstValue;
            } else if (category == "RN1") {
                wd.rn1 = fcstValue;
            } else if (category == "SKY") {
                wd.sky = fcstValue;
            } else if (category == "UUU") {
                wd.uuu = fcstValue;
            } else if (category == "VVV") {
                wd.vvv = fcstValue;
            } else if (category == "REH") {
                wd.reh = fcstValue;
            } else if (category == "PTY") {
                wd.pty = fcstValue;
            } else if (category == "LGT") {
                wd.lgt = fcstValue;
            } else if (category == "VEC") {
                wd.vec = fcstValue;
            } else if (category == "WSD") {
                wd.wsd = fcstValue;
            }
        }
    }

    _weatherUiData.time = wd.time;
    _weatherUiData.sky = wd.sky.toInt();
    _weatherUiData.wind = wd.wsd.toInt();
    _weatherUiData.temperature = wd.t1h.toInt();
    _weatherUiData.rain = wd.rn1.toInt();

    _isValid = true;

    qDebug() << "time:" << _weatherUiData.time.toString("yyyyMMddhhmm")
            << "sky:" << _weatherUiData.sky
            << "wind:" << _weatherUiData.wind
            << "temperature:" << _weatherUiData.temperature
            << "rain:" << _weatherUiData.rain;

    notifyWeatherData();
}

static double calculateDistance(double lon1, double lat1, double lon2, double lat2)
{
    double dLat = qDegreesToRadians(lat2 - lat1);
    double dLon = qDegreesToRadians(lon2 - lon1);

    lat1 = qDegreesToRadians(lat1);
    lat2 = qDegreesToRadians(lat2);

    double a = qSin(dLat / 2) * qSin(dLat / 2) +
               qSin(dLon / 2) * qSin(dLon / 2) * qCos(lat1) * qCos(lat2);
    double c = 2 * qAtan2(qSqrt(a), qSqrt(1 - a));

    return 6371 * c;
}

bool WeatherInfoProvider::findRegionName(double longitude, double latitude, LocationData& outData)
{
    QFile file(":/json/LocationInfo.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Could not open the file.";
        return false;
    }

    QJsonDocument jsonDocument = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (jsonDocument.isNull()) {
        qDebug() << "Failed to create JSON document.";
        return false;
    }

    QJsonArray jsonArray = jsonDocument.array();

    // initial value
    double minDistance = std::numeric_limits<double>::max();
    LocationData closestLocation;

    // compare distance to each item
    for (const QJsonValue &value : jsonArray) {
        QJsonObject jsonObject = value.toObject();

        LocationData currentLocation;
        currentLocation.step1 = jsonObject["1step"].toString();
        currentLocation.step2 = jsonObject["2step"].toString();
        currentLocation.step3 = jsonObject["3step"].toString();
        currentLocation.x = jsonObject["X"].toDouble();
        currentLocation.y = jsonObject["Y"].toDouble();
        currentLocation.longitude = jsonObject["longitude"].toDouble();
        currentLocation.latitude = jsonObject["latitude"].toDouble();

        double distance = calculateDistance(longitude, latitude,
                                            currentLocation.longitude, currentLocation.latitude);

        if (distance < minDistance) {
            minDistance = distance;
            closestLocation = currentLocation;
        }
    }

    outData.step1 = closestLocation.step1;
    outData.step2 = closestLocation.step2;
    outData.step3 = closestLocation.step3;
    outData.x = closestLocation.x;
    outData.y = closestLocation.y;

    qDebug() << "Closest Location:";
    qDebug() << "lon:" << longitude;
    qDebug() << "lat:" << latitude;
    qDebug() << "1step:" << closestLocation.step1;
    qDebug() << "2step:" << closestLocation.step2;
    qDebug() << "3step:" << closestLocation.step3;
    qDebug() << "X:" << closestLocation.x;
    qDebug() << "Y:" << closestLocation.y;

    return true;
}

QString WeatherInfoProvider::getWeatherApiKey(void)
{
    QFile file(":/json/WeatherApiKey.json");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Could not open WeatherApiKey.json file.";
        return QString();
    }
    QJsonDocument jsonDocument = QJsonDocument::fromJson(file.readAll());
    file.close();
    if (jsonDocument.isNull()) {
        qDebug() << "Failed to create JSON document.";
        return QString();
    }

    QJsonArray jsonArray = jsonDocument.array();
    for (const QJsonValue &value : jsonArray) {
        QJsonObject jsonObject = value.toObject();

        return jsonObject["weather_api_key"].toString();
    }
    return QString();
}
