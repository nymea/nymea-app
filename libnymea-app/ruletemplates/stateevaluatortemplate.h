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

#ifndef STATEEVALUATORTEMPLATE_H
#define STATEEVALUATORTEMPLATE_H

#include "statedescriptortemplate.h"

#include <QObject>

class StateEvaluatorTemplates;

class StateEvaluatorTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(StateDescriptorTemplate* stateDescriptorTemplate READ stateDescriptorTemplate CONSTANT)
    Q_PROPERTY(StateOperator stateOperator READ stateOperator CONSTANT)
    Q_PROPERTY(StateEvaluatorTemplates* childEvaluatorTemplates READ childEvaluatorTemplates CONSTANT)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)

public:
    enum StateOperator {
        StateOperatorAnd,
        StateOperatorOr
    };
    Q_ENUM(StateOperator)

    explicit StateEvaluatorTemplate(StateDescriptorTemplate* stateDescriptorTemplate, StateOperator stateOperator = StateOperatorAnd, QObject *parent = nullptr);

    StateDescriptorTemplate* stateDescriptorTemplate() const;
    StateOperator stateOperator() const;
    StateEvaluatorTemplates* childEvaluatorTemplates() const;
    QStringList interfaces() const;

private:
    StateDescriptorTemplate* m_stateDescriptorTemplate = nullptr;
    StateOperator m_stateOperator = StateOperatorAnd;
    StateEvaluatorTemplates *m_childEvaluatorTemplates = nullptr;
};

#include <QAbstractListModel>

class StateEvaluatorTemplates: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)

public:
    StateEvaluatorTemplates(QObject *parent = nullptr): QAbstractListModel(parent) {}
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }

    Q_INVOKABLE StateEvaluatorTemplate* get(int index) const {
        if (index < 0 || index >= m_list.count()) {
            return nullptr;
        }
        return m_list.at(index);
    }

    void addStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate) {
        stateEvaluatorTemplate->setParent(this);
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(stateEvaluatorTemplate);
        endInsertRows();
    }
private:
    QList<StateEvaluatorTemplate*> m_list;
};

#endif // STATEEVALUATORTEMPLATE_H
