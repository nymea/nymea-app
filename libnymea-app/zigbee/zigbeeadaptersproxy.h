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
    Q_PROPERTY(QString serialPortFilter READ serialPortFilter WRITE setSerialPortFilter NOTIFY serialPortFilterChanged)

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

    QString serialPortFilter() const;
    void setSerialPortFilter(const QString &serialPortFilter);

    Q_INVOKABLE ZigbeeAdapter* get(int index) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void countChanged();
    void managerChanged();
    void hardwareFilterChanged(HardwareFilter hardwareFilter);
    void onlyUnusedChanged();
    void serialPortFilterChanged();

private:
    ZigbeeManager *m_manager = nullptr;
    HardwareFilter m_hardwareFilter = HardwareFilterNone;
    bool m_onlyUnused = false;
    QString m_serialPortFilter;
};

#endif // ZIGBEEADAPTERSPROXY_H
