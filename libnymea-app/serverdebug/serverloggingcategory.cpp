/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2024, nymea GmbH
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
