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

#include "backupfilesproxymodel.h"

#include <QCollator>

BackupFilesProxyModel::BackupFilesProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    setSortRole(BackupFiles::RoleTimestamp);
    sort(0, Qt::DescendingOrder);

    connect(this, &QAbstractItemModel::rowsInserted, this, &BackupFilesProxyModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &BackupFilesProxyModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &BackupFilesProxyModel::countChanged);
}

BackupFiles *BackupFilesProxyModel::backupFiles() const
{
    return m_backupFiles;
}

void BackupFilesProxyModel::setBackupFiles(BackupFiles *backupFiles)
{
    if (m_backupFiles == backupFiles) {
        return;
    }

    if (m_backupFiles) {
        disconnect(m_backupFiles, nullptr, this, nullptr);
    }

    m_backupFiles = backupFiles;
    setSourceModel(m_backupFiles);

    if (m_backupFiles) {
        connect(m_backupFiles, &BackupFiles::countChanged, this, &BackupFilesProxyModel::countChanged);
    }

    emit backupFilesChanged();
    emit countChanged();
    invalidate();
}

QString BackupFilesProxyModel::nameFilter() const
{
    return m_nameFilter;
}

void BackupFilesProxyModel::setNameFilter(const QString &nameFilter)
{
    if (m_nameFilter == nameFilter) {
        return;
    }

    m_nameFilter = nameFilter;
    emit nameFilterChanged();
    invalidateFilter();
    emit countChanged();
}

BackupFile *BackupFilesProxyModel::get(int index) const
{
    if (!m_backupFiles || index < 0 || index >= rowCount()) {
        return nullptr;
    }

    return m_backupFiles->get(mapToSource(this->index(index, 0)).row());
}

bool BackupFilesProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (!m_backupFiles) {
        return false;
    }

    if (m_nameFilter.isEmpty()) {
        return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
    }

    BackupFile *backupFile = m_backupFiles->get(sourceRow);
    if (!backupFile) {
        return false;
    }

    return backupFile->fileName().contains(m_nameFilter, Qt::CaseInsensitive)
        || backupFile->serverVersion().contains(m_nameFilter, Qt::CaseInsensitive);
}

bool BackupFilesProxyModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
    const QVariant leftData = sourceModel()->data(sourceLeft, sortRole());
    const QVariant rightData = sourceModel()->data(sourceRight, sortRole());

    if (sortRole() == BackupFiles::RoleTimestamp) {
        return leftData.toDateTime() < rightData.toDateTime();
    }

    if (sortRole() == BackupFiles::RoleSize) {
        return leftData.toDouble() < rightData.toDouble();
    }

    QCollator collator;
    collator.setNumericMode(true);
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    return collator.compare(leftData.toString(), rightData.toString()) < 0;
}
