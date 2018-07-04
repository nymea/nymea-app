/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef PLUGIN_H
#define PLUGIN_H

#include <QObject>
#include <QUuid>

#include "params.h"
#include "paramtypes.h"

class Plugin : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QUuid pluginId READ pluginId CONSTANT)
    Q_PROPERTY(ParamTypes *paramTypes READ paramTypes CONSTANT)
    Q_PROPERTY(Params *params READ params CONSTANT)

public:
    explicit Plugin(QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QUuid pluginId() const;
    void setPluginId(const QUuid pluginId);

    ParamTypes *paramTypes();
    void setParamTypes(ParamTypes *paramTypes);

    Params *params();
    void setParams(Params *params);

private:
    QString m_name;
    QUuid m_pluginId;
    ParamTypes *m_paramTypes = nullptr;
    Params *m_params = nullptr;
};

#endif // PLUGIN_H
