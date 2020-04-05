/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
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

#ifndef STATETYPE_H
#define STATETYPE_H

#include <QVariant>
#include <QObject>
#include <QUuid>

#include "types.h"

class StateType : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QString type READ type CONSTANT)
    Q_PROPERTY(int index READ index CONSTANT)
    Q_PROPERTY(QVariant defaultValue READ defaultValue CONSTANT)
    Q_PROPERTY(QVariantList allowedValues READ allowedValues CONSTANT)
    Q_PROPERTY(Types::Unit unit READ unit CONSTANT)
    Q_PROPERTY(Types::IOType ioType READ ioType CONSTANT)
    Q_PROPERTY(QString unitString READ unitString CONSTANT)
    Q_PROPERTY(QVariant minValue READ minValue CONSTANT)
    Q_PROPERTY(QVariant maxValue READ maxValue CONSTANT)

public:
    StateType(QObject *parent = nullptr);

    QUuid id() const;
    void setId(const QUuid &id);

    QString name() const;
    void setName(const QString &name);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    QString type() const;
    void setType(const QString &type);
    void setType(QVariant::Type type);

    int index() const;
    void setIndex(const int &index);

    QVariant defaultValue() const;
    void setDefaultValue(const QVariant &defaultValue);

    QVariantList allowedValues() const;
    void setAllowedValues(const QVariantList &allowedValues);

    Types::Unit unit() const;
    void setUnit(const Types::Unit &unit);

    Types::IOType ioType() const;
    void setIOType(Types::IOType ioType);

    QString unitString() const;
    void setUnitString(const QString &unitString);

    QVariant minValue() const;
    void setMinValue(const QVariant &minValue);

    QVariant maxValue() const;
    void setMaxValue(const QVariant &maxValue);

private:
    QUuid m_id;
    QString m_name;
    QString m_displayName;
    QString m_type;
    int m_index;
    QVariant m_defaultValue;
    QVariantList m_allowedValues;
    Types::Unit m_unit = Types::UnitNone;
    Types::IOType m_ioType = Types::IOTypeNone;
    QString m_unitString;
    QVariant m_minValue;
    QVariant m_maxValue;
};

#endif // STATETYPE_H
