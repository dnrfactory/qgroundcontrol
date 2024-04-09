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
#include <QProcess>

class MediaPlayerProxy : public QObject
{
	Q_OBJECT

private:
    QString _mediaPlayerPath;
    QProcess* _mediaPlayerProcess;
    QString _mediaSourcePath;
    bool _isReserveLaunch;

public:
    MediaPlayerProxy(QObject* parent = nullptr);
    ~MediaPlayerProxy(void);

    Q_INVOKABLE void play(const QString& source);

private slots:
    void _launchMediaPlayer(void);
    void _onMediaPlayerProcessState(QProcess::ProcessState newState);
};
