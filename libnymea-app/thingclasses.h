// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
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

#ifndef THINGCLASSES_H
#define THINGCLASSES_H

#include <QAbstractListModel>

#include "types/thingclass.h"

class ThingClasses : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Role {
        RoleId,
        RoleName,
        RoleDisplayName,
        RolePluginId,
        RoleVendorId,
        RoleInterfaces,
        RoleBaseInterface
    };

    explicit ThingClasses(QObject *parent = nullptr);

    QList<ThingClass *> thingClasses();

    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE int count() const;
    Q_INVOKABLE ThingClass *get(int index) const;
    Q_INVOKABLE ThingClass *getThingClass(QUuid thingClassId) const;

    void addThingClass(ThingClass *thingClass);

    void clearModel();

signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<ThingClass *> m_thingClasses;

};

#endif // THINGCLASSES_H
