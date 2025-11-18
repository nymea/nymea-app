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

#ifndef RULE_H
#define RULE_H

#include <QObject>
#include <QUuid>

class EventDescriptors;
class RuleActions;
class StateEvaluator;
class TimeDescriptor;

class Rule : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(bool executable READ executable WRITE setExecutable NOTIFY executableChanged)
    Q_PROPERTY(EventDescriptors* eventDescriptors READ eventDescriptors CONSTANT)
    Q_PROPERTY(StateEvaluator* stateEvaluator READ stateEvaluator WRITE setStateEvaluator NOTIFY stateEvaluatorChanged)
    Q_PROPERTY(RuleActions* actions READ actions CONSTANT)
    Q_PROPERTY(RuleActions* exitActions READ exitActions CONSTANT)
    Q_PROPERTY(TimeDescriptor* timeDescriptor READ timeDescriptor CONSTANT)
public:
    explicit Rule(const QUuid &id = QUuid(), QObject *parent = nullptr);
    ~Rule();

    QUuid id() const;

    QString name() const;
    void setName(const QString &name);

    bool enabled() const;
    void setEnabled(bool enabled);

    bool active() const;
    void setActive(bool active);

    bool executable() const;
    void setExecutable(bool executable);

    EventDescriptors* eventDescriptors() const;
    StateEvaluator *stateEvaluator() const;
    RuleActions* actions() const;
    RuleActions* exitActions() const;
    TimeDescriptor* timeDescriptor() const;

    Q_INVOKABLE StateEvaluator* createStateEvaluator() const;

    Q_INVOKABLE void setStateEvaluator(StateEvaluator* stateEvaluator);

    Q_INVOKABLE Rule *clone() const;

    Q_INVOKABLE bool compare(Rule* other) const;
    bool operator==(Rule *other) const;

signals:
    void nameChanged();
    void enabledChanged();
    void activeChanged();
    void executableChanged();
    void stateEvaluatorChanged();

private:
    QUuid m_id;
    QString m_name;
    bool m_enabled = true;
    bool m_active = false;
    bool m_executable = false;
    EventDescriptors *m_eventDescriptors = nullptr;
    StateEvaluator *m_stateEvaluator = nullptr;
    RuleActions *m_actions = nullptr;
    RuleActions *m_exitActions = nullptr;
    TimeDescriptor *m_timeDescriptor = nullptr;
};

QDebug operator<<(QDebug &dbg, Rule *rule);
QDebug printStateEvaluator(QDebug &dbg, StateEvaluator *stateEvaluator, int indentLevel = 1);

#endif // RULE_H
