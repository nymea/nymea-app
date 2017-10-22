/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2015 Simon Stuerz <stuerz.simon@gmail.com>               *
 *                                                                         *
 *  This file is part of guh-ubuntu.                                       *
 *                                                                         *
 *  guh-ubuntu is free software: you can redistribute it and/or modify     *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-ubuntu is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-ubuntu. If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef GUHHOST_H
#define GUHHOST_H

#include <QUuid>
#include <QObject>
#include <QHostAddress>

class GuhHost : public QObject
{
    Q_OBJECT
public:
    explicit GuhHost(QObject *parent = 0);

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

#endif // GuhHost_H
