/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "MediaPlayerProxy.h"
#include <QStringList>
#include <QTimer>
#include <QDebug>

MediaPlayerProxy::MediaPlayerProxy(QObject* parent)
: QObject(parent), _mediaPlayerPath("./dnrmediaplayer"), _mediaPlayerProcess(new QProcess(this))
, _isReserveLaunch(false)
{
    connect(_mediaPlayerProcess, &QProcess::stateChanged, this, &MediaPlayerProxy::_onMediaPlayerProcessState);
}

MediaPlayerProxy::~MediaPlayerProxy(void)
{
}

void MediaPlayerProxy::play(const QString& source)
{
    qDebug() << "MediaPlayerProxy::play " << source;

    _mediaSourcePath = QString("file://%1").arg(source);

    if (_mediaPlayerProcess->state() != QProcess::NotRunning) {
        _mediaPlayerProcess->terminate();
        _isReserveLaunch = true;
    } else {
        _launchMediaPlayer();
    }
}

void MediaPlayerProxy::_launchMediaPlayer(void)
{
    qDebug() << "MediaPlayerProxy::_launchMediaPlayer";

    QStringList arguments;
    arguments << _mediaSourcePath;

    _mediaPlayerProcess->start(_mediaPlayerPath, arguments);
}

void MediaPlayerProxy::_onMediaPlayerProcessState(QProcess::ProcessState newState)
{
    qDebug() << "MediaPlayerProxy::_onMediaPlayerProcessState " << newState;

    switch (newState) {
    case QProcess::NotRunning:
        if (_isReserveLaunch) {
            QTimer::singleShot(100, this, &MediaPlayerProxy::_launchMediaPlayer);
        }
        break;
    case QProcess::Starting:
        break;
    case QProcess::Running:
        _isReserveLaunch = false;
        break;
    }
}