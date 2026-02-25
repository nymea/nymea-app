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

#ifndef RULETEMPLATE_H
#define RULETEMPLATE_H

#include <QObject>

#include "eventdescriptortemplate.h"
#include "ruleactiontemplate.h"
#include "stateevaluatortemplate.h"
#include "timedescriptortemplate.h"

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
