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

#ifndef TAG_H
#define TAG_H

#include <QObject>
#include <QUuid>

class Tag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QUuid deviceId READ thingId CONSTANT)
    Q_PROPERTY(QUuid ruleId READ ruleId CONSTANT)
    Q_PROPERTY(QString tagId READ tagId CONSTANT)
    Q_PROPERTY(QString value READ value NOTIFY valueChanged)

public:
    explicit Tag(const QString &tagId, const QString &value, QObject *parent = nullptr);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QUuid ruleId() const;
    void setRuleId(const QUuid &ruleId);

    QString tagId() const;

    QString value() const;
    void setValue(const QString &value);

signals:
    void valueChanged();

private:
    QUuid m_thingId;
    QUuid m_ruleId;
    QString m_tagId;
    QString m_value;
};

#endif // TAG_H
