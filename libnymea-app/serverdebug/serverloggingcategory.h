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
