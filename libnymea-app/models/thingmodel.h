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

#ifndef THINGMODEL_H
#define THINGMODEL_H

#include <QObject>

#include "types/thing.h"
#include "types/thingclass.h"

class ThingModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_PROPERTY(Thing* thing READ thing WRITE setThing NOTIFY thingChanged)

    Q_PROPERTY(bool showStates READ showStates WRITE setShowStates NOTIFY showStatesChanged)
    Q_PROPERTY(bool showActions READ showActions WRITE setShowActions NOTIFY showActionsChanged)
    Q_PROPERTY(bool showEvents READ showEvents WRITE setShowEvents NOTIFY showEventsChanged)

public:
    enum Roles {
        RoleId,
        RoleType,
        RoleName,
        RoleDisplayName,
        RoleWritable
    };
    Q_ENUM(Roles)
    enum Type {
        TypeStateType,
        TypeActionType,
        TypeEventType
    };
    Q_ENUM(Type)

    explicit ThingModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariant getData(int index, int role) const;

    Thing* thing() const;
    void setThing(Thing *device);

    bool showStates() const;
    void setShowStates(bool showStates);

    bool showActions() const;
    void setShowActions(bool showActions);

    bool showEvents() const;
    void setShowEvents(bool showEvents);

signals:
    void thingChanged();

    void countChanged();

    bool showStatesChanged();
    bool showActionsChanged();
    bool showEventsChanged();

private:
    void updateList();

private:
    Thing *m_device = nullptr;

    bool m_showStates = true;
    bool m_showActions = true;
    bool m_showEvents = true;

    QList<QUuid> m_list;
};

#endif // THINGMODEL_H
