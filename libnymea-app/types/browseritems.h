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

#ifndef BROWSERITEMS_H
#define BROWSERITEMS_H

#include <QAbstractListModel>
#include <QUuid>

class BrowserItem;

class BrowserItems: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:
    enum Roles {
        RoleId,
        RoleDisplayName,
        RoleDescription,
        RoleIcon,
        RoleThumbnail,
        RoleBrowsable,
        RoleExecutable,
        RoleDisabled,
        RoleActionTypeIds,

        RoleMediaIcon,
    };
    Q_ENUM(Roles)

    explicit BrowserItems(const QUuid &thingId, const QString &itemId, QObject *parent = nullptr);
    virtual ~BrowserItems() override;

    QUuid thingId() const;
    QString itemId() const;

    bool busy() const;

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    virtual void addBrowserItem(BrowserItem *browserItem);

    void removeItem(BrowserItem *browserItem);

    QList<BrowserItem*> list() const;
    void setBusy(bool busy);

    Q_INVOKABLE virtual BrowserItem* get(int index) const;
    Q_INVOKABLE virtual BrowserItem* getBrowserItem(const QString &itemId);

//    void clear();

signals:
    void countChanged();
    void busyChanged();

protected:
    bool m_busy = false;
    QList<BrowserItem*> m_list;

    QUuid m_thingId;
    QString m_itemId;
};

#endif // BROWSERITEMS_H
