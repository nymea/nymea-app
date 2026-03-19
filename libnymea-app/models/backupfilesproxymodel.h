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

#ifndef BACKUPFILESPROXYMODEL_H
#define BACKUPFILESPROXYMODEL_H

#include <QSortFilterProxyModel>

#include "backupfiles.h"

class BackupFilesProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(BackupFiles *backupFiles READ backupFiles WRITE setBackupFiles NOTIFY backupFilesChanged FINAL)
    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged FINAL)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)

public:
    explicit BackupFilesProxyModel(QObject *parent = nullptr);

    BackupFiles *backupFiles() const;
    void setBackupFiles(BackupFiles *backupFiles);

    QString nameFilter() const;
    void setNameFilter(const QString &nameFilter);

    Q_INVOKABLE BackupFile *get(int index) const;

signals:
    void backupFilesChanged();
    void nameFilterChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
    BackupFiles *m_backupFiles = nullptr;
    QString m_nameFilter;
};

#endif // BACKUPFILESPROXYMODEL_H
