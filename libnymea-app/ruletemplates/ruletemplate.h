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

#ifndef RULETEMPLATE_H
#define RULETEMPLATE_H

#include <QObject>

class EventDescriptorTemplates;
class RuleActionTemplates;
class StateEvaluatorTemplate;
class TimeDescriptorTemplate;

class RuleTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QString ruleNameTemplate READ ruleNameTemplate CONSTANT)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
    Q_PROPERTY(EventDescriptorTemplates* eventDescriptorTemplates READ eventDescriptorTemplates CONSTANT)
    Q_PROPERTY(TimeDescriptorTemplate* timeDescriptorTemplate READ timeDescriptorTemplate CONSTANT)
    Q_PROPERTY(StateEvaluatorTemplate* stateEvaluatorTemplate READ stateEvaluatorTemplate CONSTANT)
    Q_PROPERTY(RuleActionTemplates* ruleActionTemplates READ ruleActionTemplates CONSTANT)
    Q_PROPERTY(RuleActionTemplates* ruleExitActionTemplates READ ruleExitActionTemplates CONSTANT)

public:
    explicit RuleTemplate(const QString &interfaceName, const QString &description, const QString &ruleNameTemplate, QObject *parent = nullptr);

    QString description() const;
    QString ruleNameTemplate() const;
    QStringList interfaces() const;

    EventDescriptorTemplates* eventDescriptorTemplates() const;
    StateEvaluatorTemplate* stateEvaluatorTemplate() const;
    void setStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate);
    TimeDescriptorTemplate* timeDescriptorTemplate() const;
    void setTimeDescriptorTemplate(TimeDescriptorTemplate *timeDescriptorTemplate);
    RuleActionTemplates* ruleActionTemplates() const;
    RuleActionTemplates* ruleExitActionTemplates() const;

private:
    QString m_interfaceName;
    QString m_description;
    QString m_ruleNameTemplate;
    EventDescriptorTemplates* m_eventDescriptorTemplates = nullptr;
    StateEvaluatorTemplate* m_stateEvaluatorTemplate = nullptr;
    TimeDescriptorTemplate* m_timeDescriptorTemplate = nullptr;
    RuleActionTemplates *m_ruleActionTemplates = nullptr;
    RuleActionTemplates *m_ruleExitActionTemplates = nullptr;
};

#endif // RULETEMPLATE_H
