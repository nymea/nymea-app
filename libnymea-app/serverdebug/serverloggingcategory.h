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

#ifndef SERVERLOGGINGCATEGORY_H
#define SERVERLOGGINGCATEGORY_H

#include <QObject>
#include <QVariantMap>

class ServerLoggingCategory : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT FINAL)
    Q_PROPERTY(ServerLoggingCategory::Type type READ type CONSTANT FINAL)
    Q_PROPERTY(ServerLoggingCategory::Level level READ level NOTIFY levelChanged FINAL)

public:
    enum Type {
        TypeSystem,
        TypePlugin,
        TypeCustom
    };
    Q_ENUM(Type)

    enum Level {
        LevelCritical,
        LevelWarning,
        LevelInfo,
        LevelDebug
    };
    Q_ENUM(Level)

    explicit ServerLoggingCategory(QObject *parent = nullptr);
    explicit ServerLoggingCategory(const QVariantMap &loggingCategoryMap, QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    Type type() const;
    void setType(Type type);

    Level level() const;
    void setLevel(Level level);

    static Level convertStringToLevel(const QString &levelString);
    static Type convertStringToType(const QString &typeString);

signals:
    void levelChanged(Level level);

private:
    QString m_name;
    Type m_type;
    Level m_level;

};

#endif // SERVERLOGGINGCATEGORY_H
