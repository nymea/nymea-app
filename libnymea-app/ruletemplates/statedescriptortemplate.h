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
