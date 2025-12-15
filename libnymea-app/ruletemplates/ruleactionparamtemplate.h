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

    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return static_cast<int>(m_list.count()); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index) Q_UNUSED(role) return QVariant(); }

    void addRuleActionParamTemplate(RuleActionParamTemplate *ruleActionParamTemplate) {
        ruleActionParamTemplate->setParent(this);
        beginInsertRows(QModelIndex(), static_cast<int>(m_list.count()), static_cast<int>(m_list.count()));
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
