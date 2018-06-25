/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                       *
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

#include "plugin.h"

Plugin::Plugin(QObject *parent) : QObject(parent)
{
    m_params = new Params(this);
}

QString Plugin::name() const
{
    return m_name;
}

void Plugin::setName(const QString &name)
{
    m_name = name;
}

QUuid Plugin::pluginId() const
{
    return m_pluginId;
}

void Plugin::setPluginId(const QUuid pluginId)
{
    m_pluginId = pluginId;
}

ParamTypes *Plugin::paramTypes()
{
    return m_paramTypes;
}

void Plugin::setParamTypes(ParamTypes *paramTypes)
{
    m_paramTypes = paramTypes;
}

Params *Plugin::params()
{
    return m_params;
}

void Plugin::setParams(Params *params)
{
    m_params = params;
}

