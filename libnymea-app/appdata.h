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

#ifndef APPDATA_H
#define APPDATA_H

#include <QQmlParserStatus>
#include <QTimer>
#include <QHash>

class Engine;

class AppData : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)

public:
    explicit AppData(QObject *parent = nullptr);
    ~AppData() override;

    void classBegin() override;
    void componentComplete() override;

    Engine *engine() const;
    void setEngine(Engine *engine);

    QString group() const;
    void setGroup(const QString &group);

signals:
    void engineChanged();
    void groupChanged();

private slots:
    void load();
    void store();

    void onPropertyChanged();

    void appDataReceived(int commandId, const QVariantMap &params);
    void appDataWritten(int commandId, const QVariantMap &params);

    void notificationReceived(const QVariantMap &notification);
private:
    Engine *m_engine = nullptr;
    QTimer m_syncTimer;
    QString m_group;

    bool m_loopLock = false;
    QHash<int, QString> m_readRequests;

};

#endif // APPDATA_H
