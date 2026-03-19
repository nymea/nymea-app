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

#include "backupfile.h"

BackupFile::BackupFile(QObject *parent)
    : QObject(parent)
{
}

BackupFile::BackupFile(const QString &fileName, const QString &serverVersion, const QDateTime &timestamp, double size, QObject *parent)
    : QObject(parent)
    , m_fileName(fileName)
    , m_serverVersion(serverVersion)
    , m_timestamp(timestamp)
    , m_size(size)
{
}

QString BackupFile::fileName() const
{
    return m_fileName;
}

void BackupFile::setFileName(const QString &fileName)
{
    if (m_fileName == fileName) {
        return;
    }

    m_fileName = fileName;
    emit fileNameChanged();
}

QString BackupFile::serverVersion() const
{
    return m_serverVersion;
}

void BackupFile::setServerVersion(const QString &serverVersion)
{
    if (m_serverVersion == serverVersion) {
        return;
    }

    m_serverVersion = serverVersion;
    emit serverVersionChanged();
}

QDateTime BackupFile::timestamp() const
{
    return m_timestamp;
}

void BackupFile::setTimestamp(const QDateTime &timestamp)
{
    if (m_timestamp == timestamp) {
        return;
    }

    m_timestamp = timestamp;
    emit timestampChanged();
}

double BackupFile::size() const
{
    return m_size;
}

void BackupFile::setSize(double size)
{
    if (qFuzzyCompare(m_size, size)) {
        return;
    }

    m_size = size;
    emit sizeChanged();
}
