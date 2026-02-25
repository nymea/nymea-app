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

#ifndef PLUGINCONFIGMANAGER_H
#define PLUGINCONFIGMANAGER_H

#include "types/params.h"
#include "types/paramtypes.h"
#include "engine.h"

#include <QObject>

class PluginConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(Plugin* plugin READ plugin WRITE setPlugin NOTIFY pluginChanged)

    Q_PROPERTY(Params *params READ params CONSTANT)

public:
    explicit PluginConfigManager(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine *engine);

    Plugin* plugin() const;
    void setPlugin(Plugin *plugin);

    Params *params();
    void setParams(Params *params);

    Q_INVOKABLE int savePluginConfig();

signals:
    void engineChanged();
    void pluginChanged();

private slots:
    void getPluginConfigResponse(int commandId, const QVariantMap &data);

private:
    Engine *m_engine = nullptr;
    Plugin* m_plugin = nullptr;
    Params *m_params = nullptr;

};

#endif // PLUGINCONFIGMANAGER_H
