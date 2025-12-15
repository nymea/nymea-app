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

#ifndef SERVERDEBUGMANAGER_H
#define SERVERDEBUGMANAGER_H

#include <QObject>

#include "engine.h"
#include "serverloggingcategories.h"

class JsonRpcClient;

class ServerDebugManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged FINAL)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged FINAL)
    Q_PROPERTY(ServerLoggingCategories *categories READ categories CONSTANT FINAL)

public:
    explicit ServerDebugManager(QObject *parent = nullptr);
    ~ServerDebugManager();

    Engine *engine() const;
    void setEngine(Engine *engine);

    ServerLoggingCategories *categories() const;

    bool fetchingData() const;

    Q_INVOKABLE void getLoggingCategories();
    Q_INVOKABLE void setLoggingLevel(const QString &name, int level);

signals:
    void engineChanged();
    void fetchingDataChanged();

private slots:
    void notificationReceived(const QVariantMap &notification);

private:
    Engine *m_engine = nullptr;
    ServerLoggingCategories *m_categories = nullptr;

    bool m_fetchingData = false;

    void init();

    Q_INVOKABLE void getLoggingCategoriesResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setLoggingCategoryLevelResponse(int commandId, const QVariantMap &params);

};

#endif // SERVERDEBUGMANAGER_H
