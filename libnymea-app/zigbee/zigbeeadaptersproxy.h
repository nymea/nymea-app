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

#ifndef ZIGBEEADAPTERSPROXY_H
#define ZIGBEEADAPTERSPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

class ZigbeeAdapter;
class ZigbeeManager;

class ZigbeeAdaptersProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    // Required
    Q_PROPERTY(ZigbeeManager* manager READ manager WRITE setManager NOTIFY managerChanged)

    // Optional filtering
    Q_PROPERTY(ZigbeeAdaptersProxy::HardwareFilter hardwareFilter READ hardwareFilter WRITE setHardwareFilter NOTIFY hardwareFilterChanged)
    Q_PROPERTY(bool onlyUnused READ onlyUnused WRITE setOnlyUnused NOTIFY onlyUnusedChanged)

public:
    enum HardwareFilter {
        HardwareFilterNone,
        HardwareFilterRecognized,
        HardwareFilterUnrecognized
    };
    Q_ENUM(HardwareFilter)

    explicit ZigbeeAdaptersProxy(QObject *parent = nullptr);

    ZigbeeManager *manager() const;
    void setManager(ZigbeeManager *manager);

    HardwareFilter hardwareFilter() const;
    void setHardwareFilter(HardwareFilter hardwareFilter);

    bool onlyUnused() const;
    void setOnlyUnused(bool onlyUnused);

    Q_INVOKABLE ZigbeeAdapter* get(int index) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void countChanged();
    void managerChanged();
    void hardwareFilterChanged(HardwareFilter hardwareFilter);
    void onlyUnusedChanged();

private:
    ZigbeeManager *m_manager = nullptr;
    HardwareFilter m_hardwareFilter = HardwareFilterNone;
    bool m_onlyUnused = false;
};

#endif // ZIGBEEADAPTERSPROXY_H
