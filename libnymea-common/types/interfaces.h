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

#ifndef INTERFACES_H
#define INTERFACES_H

#include <QAbstractListModel>
#include <QVariant>
#include <QSortFilterProxyModel>

class Interface;
class ParamType;
class ParamTypes;
class Devices;

class Interfaces : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)

public:
    enum Roles {
        RoleName,
        RoleDisplayName
    };
    explicit Interfaces(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE Interface* get(int index) const;
    Q_INVOKABLE Interface* findByName(const QString &name) const;

private:
    QList<Interface*> m_list;

    // helpers to populate the model
    void addInterface(const QString &name, const QString &displayName);
    void addEventType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes);
    void addActionType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes);
    void addStateType(const QString &interfaceName, const QString &name, QVariant::Type type, bool writable, const QString &displayName, const QString &displayNameEvent, const QString &displayNameAction = QString());

    ParamTypes* createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue = QVariant(), const QVariant &minValue = QVariant(), const QVariant &maxValue = QVariant());
    void addParamType(ParamTypes* paramTypes, const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue = QVariant(), const QVariant &minValue = QVariant(), const QVariant &maxValue = QVariant());
};


#endif // INTERFACES_H
