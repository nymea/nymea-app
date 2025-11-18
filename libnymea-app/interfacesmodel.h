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

#ifndef INTERFACESMODEL_H
#define INTERFACESMODEL_H

#include <QObject>
#include <QAbstractListModel>

#include "things.h"

class Engine;
class ThingsProxy;

class InterfacesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    // Required
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)

    // Optional filters
    Q_PROPERTY(ThingsProxy* things READ things WRITE setThings NOTIFY thingsChanged)
    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(bool showUncategorized READ showUncategorized WRITE setShowUncategorized NOTIFY showUncategorizedChanged)

public:
    enum Roles {
        RoleName
    };
    Q_ENUMS(Roles)

    explicit InterfacesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Engine* engine() const;
    void setEngine(Engine *engine);

    ThingsProxy* things() const;
    void setThings(ThingsProxy *things);

    QStringList shownInterfaces() const;
    void setShownInterfaces(const QStringList &shownInterfaces);

    bool showUncategorized() const;
    void setShowUncategorized(bool showUncategorized);

    Q_INVOKABLE QString get(int index) const;

signals:
    void countChanged();
    void engineChanged();
    void thingsChanged();
    void shownInterfacesChanged();
    void showUncategorizedChanged();

private slots:
    void syncInterfaces();
    void rowsChanged(const QModelIndex &index, int first, int last);

private:
    Engine *m_engine = nullptr;
    QMetaObject::Connection m_thingClassesCountChangedConnection;

    QStringList m_interfaces;

    ThingsProxy *m_thingsProxy = nullptr;
    QMetaObject::Connection m_thingsCountChangedConnection;

    QStringList m_shownInterfaces;
    bool m_showUncategorized = false;
};

class InterfacesSortModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(InterfacesModel* interfacesModel READ interfacesModel WRITE setInterfacesModel NOTIFY interfacesModelChanged)

public:
    InterfacesSortModel(QObject *parent = nullptr);

    InterfacesModel* interfacesModel() const;
    void setInterfacesModel(InterfacesModel* interfacesModel);

    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;

    Q_INVOKABLE QString get(int index) const;

signals:
    void countChanged();
    void interfacesModelChanged();

private:
    InterfacesModel* m_interfacesModel = nullptr;
};

#endif // INTERFACESMODEL_H
