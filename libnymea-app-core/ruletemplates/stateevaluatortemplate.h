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
