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

#ifndef STATEDESCRIPTORTEMPLATE_H
#define STATEDESCRIPTORTEMPLATE_H

#include <QObject>
#include <QVariant>

class StateDescriptorTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString interfaceName READ interfaceName CONSTANT)
    Q_PROPERTY(QString stateName READ stateName CONSTANT)
    Q_PROPERTY(int selectionId READ selectionId CONSTANT)
    Q_PROPERTY(SelectionMode selectionMode READ selectionMode CONSTANT)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator CONSTANT)
    Q_PROPERTY(QVariant value READ value CONSTANT)

public:
    enum SelectionMode {
        SelectionModeAny,
        SelectionModeDevice,
        SelectionModeInterface,
    };
    Q_ENUM(SelectionMode)
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    explicit StateDescriptorTemplate(const QString &interfaceName, const QString &stateName, int selectionId, SelectionMode selectionMode, ValueOperator valueOperator = ValueOperatorEquals, const QVariant &value = QVariant(), QObject *parent = nullptr);

    QString interfaceName() const;
    QString stateName() const;
    int selectionId() const;
    SelectionMode selectionMode() const;
    ValueOperator valueOperator() const;
    QVariant value() const;

private:
    QString m_interfaceName;
    QString m_stateName;
    int m_selectionId = 0;
    SelectionMode m_selectionMode = SelectionModeAny;
    ValueOperator m_valueOperator = ValueOperatorEquals;
    QVariant m_value;
};

#endif // STATEDESCRIPTORTEMPLATE_H
