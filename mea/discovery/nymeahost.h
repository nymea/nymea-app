/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of mea.                                       *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef NYMEAHOST_H
#define NYMEAHOST_H

#include <QUuid>
#include <QObject>
#include <QHostAddress>

class NymeaHost : public QObject
{
    Q_OBJECT
public:
    explicit NymeaHost(QObject *parent = 0);

    QString name() const;
    void setName(const QString &name);

    QString webSocketUrl() const;
    void setWebSocketUrl(const QString &webSocketUrl);

    QString hostAddress() const;
    void setHostAddress(const QString &hostAddress);

    QUuid uuid() const;
    void setUuid(const QUuid &uuid);

private:
    QString m_name;
    QString m_webSocketUrl;
    QString m_hostAddress;
    QUuid m_uuid;

};

#endif // NYMEAHOST_H
