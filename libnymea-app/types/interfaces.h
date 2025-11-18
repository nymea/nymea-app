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

#ifndef INTERFACES_H
#define INTERFACES_H

#include <QAbstractListModel>
#include <QVariant>
#include <QSortFilterProxyModel>

class Interface;
class ParamType;
class ParamTypes;
class Things;

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
    QHash<QString, Interface*> m_hash;

    // helpers to populate the model
    void addInterface(const QString &name, const QString &displayName, const QStringList &extends = QStringList());
    void addEventType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes);
    void addActionType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes);
    void addStateType(const QString &interfaceName, const QString &name, QVariant::Type type, bool writable, const QString &displayName, const QString &displayNameEvent, const QString &displayNameAction = QString(), const QVariant &min = QVariant(), const QVariant &max = QVariant());

    ParamTypes* createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue = QVariant(), const QVariant &minValue = QVariant(), const QVariant &maxValue = QVariant());
    ParamTypes* createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue, const QVariantList &allowedValues);
    void addParamType(ParamTypes* paramTypes, const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue = QVariant(), const QVariant &minValue = QVariant(), const QVariant &maxValue = QVariant());
};


#endif // INTERFACES_H
