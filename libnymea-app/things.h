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

#ifndef THINGS_H
#define THINGS_H

#include "types/thing.h"
#include "types/thingclass.h"

#include <QAbstractListModel>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(dcThingManager)

class Things : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleName,
        RoleId,
        RoleParentId,
        RoleThingClass,
        RoleSetupStatus,
        RoleSetupDisplayMessage,
        RoleInterfaces,
        RoleBaseInterface,
        RoleMainInterface
    };
    Q_ENUM(Roles)

    explicit Things(QObject *parent = nullptr);

    QList<Thing *> devices();

    Q_INVOKABLE Thing *get(int index) const;
    Q_INVOKABLE Thing *getThing(const QUuid &thingId) const;
    Q_INVOKABLE int indexOf(Thing *thing) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role = RoleName) const override;

    void addThing(Thing *thing);
    void addThings(const QList<Thing*> things);
    void removeThing(Thing *thing);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void thingAdded(Thing *device);
    void thingRemoved(Thing *device);

private:
    QList<Thing *> m_things;

};

#endif // THINGS_H
