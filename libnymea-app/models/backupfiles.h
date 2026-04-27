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

#ifndef BACKUPFILES_H
#define BACKUPFILES_H

#include <QAbstractListModel>
#include <QPointer>

#include "backupfile.h"

class BackupFiles : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)

public:
    enum Roles {
        RoleBackupFile = Qt::UserRole + 1,
        RoleFileName,
        RoleServerVersion,
        RoleTimestamp,
        RoleSize
    };
    Q_ENUM(Roles)

    explicit BackupFiles(QObject *parent = nullptr);
    ~BackupFiles() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE BackupFile *get(int index) const;

    void clear();
    void setBackupFiles(const QVariantList &backupFiles);

signals:
    void countChanged();

private:
    QList<QPointer<BackupFile>> m_backupFiles;
};

#endif // BACKUPFILES_H
