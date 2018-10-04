/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef PARAM_H
#define PARAM_H

#include <QObject>
#include <QString>
#include <QVariant>

class Param : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString paramTypeId READ paramTypeId WRITE setParamTypeId NOTIFY paramTypeIdChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    Param(const QString &paramTypeId = QString(), const QVariant &value = QVariant(), QObject *parent = nullptr);
    Param(QObject *parent);

    QString paramTypeId() const;
    void setParamTypeId(const QString &paramTypeId);

    QVariant value() const;
    void setValue(const QVariant &value);

signals:
    void paramTypeIdChanged();
    void valueChanged();

protected:
    QString m_paramTypeId;
    QVariant m_value;
};

#endif // PARAM_H
