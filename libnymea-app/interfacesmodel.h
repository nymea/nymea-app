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
