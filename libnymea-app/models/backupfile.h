// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef BACKUPFILE_H
#define BACKUPFILE_H

#include <QObject>
#include <QDateTime>

class BackupFile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged FINAL)
    Q_PROPERTY(QString serverVersion READ serverVersion NOTIFY serverVersionChanged FINAL)
    Q_PROPERTY(QDateTime timestamp READ timestamp NOTIFY timestampChanged FINAL)
    Q_PROPERTY(double size READ size NOTIFY sizeChanged FINAL)

public:
    explicit BackupFile(QObject *parent = nullptr);
    BackupFile(const QString &fileName, const QString &serverVersion, const QDateTime &timestamp, double size, QObject *parent = nullptr);

    QString fileName() const;
    void setFileName(const QString &fileName);

    QString serverVersion() const;
    void setServerVersion(const QString &serverVersion);

    QDateTime timestamp() const;
    void setTimestamp(const QDateTime &timestamp);

    double size() const;
    void setSize(double size);

signals:
    void fileNameChanged();
    void serverVersionChanged();
    void timestampChanged();
    void sizeChanged();

private:
    QString m_fileName;
    QString m_serverVersion;
    QDateTime m_timestamp;
    double m_size = 0;
};

Q_DECLARE_METATYPE(BackupFile *)

#endif // BACKUPFILE_H
