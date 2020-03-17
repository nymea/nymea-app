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

#ifndef RULEACTIONPARAMTEMPLATE_H
#define RULEACTIONPARAMTEMPLATE_H

#include "types/ruleactionparam.h"

#include <QObject>
#include <QAbstractListModel>

class RuleActionParamTemplate : public RuleActionParam
{
    Q_OBJECT
    Q_PROPERTY(QString eventInterface READ eventInterface CONSTANT)
    Q_PROPERTY(QString eventName READ eventName CONSTANT)
    Q_PROPERTY(QString eventParamName READ eventParamName CONSTANT)
public:
    explicit RuleActionParamTemplate(const QString &paramName, const QVariant &value, QObject *parent = nullptr);
    explicit RuleActionParamTemplate(const QString &paramName, const QString &eventInterface, const QString &eventName, const QString &eventParamName, QObject *parent = nullptr);
    explicit RuleActionParamTemplate(QObject *parent = nullptr);

    QString eventInterface() const;
    void setEventInterface(const QString &eventInterface);

    QString eventName() const;
    void setEventName(const QString &eventName);

    QString eventParamName() const;
    void setEventParamName(const QString &eventParamName);

private:
    QString m_eventInterface;
    QString m_eventName;
    QString m_eventParamName;
};


class RuleActionParamTemplate;

class RuleActionParamTemplates : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    explicit RuleActionParamTemplates(QObject *parent = nullptr): QAbstractListModel(parent) {}

    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index) Q_UNUSED(role) return QVariant(); }

    void addRuleActionParamTemplate(RuleActionParamTemplate *ruleActionParamTemplate) {
        ruleActionParamTemplate->setParent(this);
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(ruleActionParamTemplate);
        endInsertRows();
        emit countChanged();
    }

    Q_INVOKABLE RuleActionParamTemplate* get(int index) const {
        if (index < 0 || index >= m_list.count()) {
            return nullptr;
        }
        return m_list.at(index);
    }

signals:
    void countChanged();

private:
    QList<RuleActionParamTemplate*> m_list;
};

#endif // RULEACTIONPARAMTEMPLATE_H
