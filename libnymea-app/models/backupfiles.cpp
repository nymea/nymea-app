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

#include "backupfiles.h"

BackupFiles::BackupFiles(QObject *parent)
    : QAbstractListModel(parent)
{
}

BackupFiles::~BackupFiles()
{
    qDeleteAll(m_backupFiles);
}

int BackupFiles::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_backupFiles.count();
}

QVariant BackupFiles::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_backupFiles.count()) {
        return QVariant();
    }

    BackupFile *backupFile = m_backupFiles.at(index.row());
    switch (role) {
    case RoleBackupFile:
        return QVariant::fromValue(backupFile);
    case RoleFileName:
        return backupFile->fileName();
    case RoleServerVersion:
        return backupFile->serverVersion();
    case RoleTimestamp:
        return backupFile->timestamp();
    case RoleSize:
        return backupFile->size();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> BackupFiles::roleNames() const
{
    return {
        {RoleBackupFile, "backupFile"},
        {RoleFileName, "fileName"},
        {RoleServerVersion, "serverVersion"},
        {RoleTimestamp, "timestamp"},
        {RoleSize, "size"}
    };
}

BackupFile *BackupFiles::get(int index) const
{
    if (index < 0 || index >= m_backupFiles.count()) {
        return nullptr;
    }

    return m_backupFiles.at(index);
}

void BackupFiles::clear()
{
    if (m_backupFiles.isEmpty()) {
        return;
    }

    beginResetModel();
    qDeleteAll(m_backupFiles);
    m_backupFiles.clear();
    endResetModel();
    emit countChanged();
}

void BackupFiles::setBackupFiles(const QVariantList &backupFiles)
{
    QList<BackupFile *> newBackupFiles;
    newBackupFiles.reserve(backupFiles.count());

    for (const QVariant &backupFileVariant: backupFiles) {
        const QVariantMap backupFileMap = backupFileVariant.toMap();
        newBackupFiles.append(new BackupFile(backupFileMap.value("fileName").toString(),
                                             backupFileMap.value("serverVersion").toString(),
                                             backupFileMap.value("timestamp").toDateTime(),
                                             backupFileMap.value("size").toDouble()));
    }

    beginResetModel();
    qDeleteAll(m_backupFiles);
    m_backupFiles = newBackupFiles;
    endResetModel();
    emit countChanged();
}
