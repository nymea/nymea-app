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

#ifndef TAG_H
#define TAG_H

#include <QObject>
#include <QUuid>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(dcTags)

class Tag : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
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

    bool equals(Tag *other) const;

signals:
    void valueChanged();

private:
    QUuid m_thingId;
    QUuid m_ruleId;
    QString m_tagId;
    QString m_value;
};

#endif // TAG_H
