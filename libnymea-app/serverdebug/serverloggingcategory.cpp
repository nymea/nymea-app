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

#include "serverloggingcategory.h"

ServerLoggingCategory::ServerLoggingCategory(QObject *parent)
    : QObject{parent}
{
}

ServerLoggingCategory::ServerLoggingCategory(const QVariantMap &loggingCategoryMap, QObject *parent)
    : QObject{parent}
{
    m_name = loggingCategoryMap.value("name").toString();
    m_level = convertStringToLevel(loggingCategoryMap.value("level").toString());
    m_type = convertStringToType(loggingCategoryMap.value("type").toString());
}

QString ServerLoggingCategory::name() const
{
    return m_name;
}

void ServerLoggingCategory::setName(const QString &name)
{
    m_name = name;
}

ServerLoggingCategory::Type ServerLoggingCategory::type() const
{
    return m_type;
}

void ServerLoggingCategory::setType(Type type)
{
    m_type = type;
}

ServerLoggingCategory::Level ServerLoggingCategory::level() const
{
    return m_level;
}

void ServerLoggingCategory::setLevel(Level level)
{
    if (m_level == level)
        return;

    m_level = level;
    emit levelChanged(m_level);
}

ServerLoggingCategory::Level ServerLoggingCategory::convertStringToLevel(const QString &levelString)
{
    Level level = LevelCritical;
    if (levelString == "LoggingLevelWarning") {
        level = LevelWarning;
    } else if (levelString == "LoggingLevelInfo") {
        level = LevelInfo;
    } else if (levelString == "LoggingLevelDebug") {
        level = LevelDebug;
    }
    return level;
}

ServerLoggingCategory::Type ServerLoggingCategory::convertStringToType(const QString &typeString)
{
    Type type = TypeSystem;
    if (typeString == "LoggingCategoryTypePlugin") {
        type = TypePlugin;
    } else if (typeString == "LoggingCategoryTypeCustom") {
        type = TypeCustom;
    }
    return type;
}
