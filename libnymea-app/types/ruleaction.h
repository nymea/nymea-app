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

#ifndef RULEACTION_H
#define RULEACTION_H

#include <QObject>
#include <QUuid>

class RuleActionParams;

class RuleAction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QUuid deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QUuid actionTypeId READ actionTypeId WRITE setActionTypeId NOTIFY actionTypeIdChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceAction READ interfaceAction WRITE setInterfaceAction NOTIFY interfaceActionChanged)
    Q_PROPERTY(QString browserItemId READ browserItemId WRITE setBrowserItemId NOTIFY browserItemIdChanged)
    Q_PROPERTY(RuleActionParams* ruleActionParams READ ruleActionParams CONSTANT)

public:
    explicit RuleAction(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid actionTypeId() const;
    void setActionTypeId(const QUuid &actionTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceAction() const;
    void setInterfaceAction(const QString &interfaceAction);

    QString browserItemId() const;
    void setBrowserItemId(const QString &browserItemId);

    RuleActionParams* ruleActionParams() const;

    RuleAction *clone() const;
    bool operator==(RuleAction *other) const;

signals:
    void deviceIdChanged();
    void actionTypeIdChanged();
    void interfaceNameChanged();
    void interfaceActionChanged();
    bool browserItemIdChanged();

private:
    QUuid m_deviceId;
    QUuid m_actionTypeId;
    QString m_interfaceName;
    QString m_interfaceAction;
    QString m_browserItemId;
    RuleActionParams *m_ruleActionParams;
};

#endif // RULEACTION_H
