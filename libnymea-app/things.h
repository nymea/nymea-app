/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
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
