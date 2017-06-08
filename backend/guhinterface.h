/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of guh-control.                                      *
 *                                                                         *
 *  guh-control is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  guh-control is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with guh-control. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef GUHINTERFACE_H
#define GUHINTERFACE_H

#include <QObject>

class GuhInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)

public:
    explicit GuhInterface(QObject *parent = 0);

    bool connected();

    virtual void sendData(const QByteArray &data) = 0;
    virtual void sendRequest(const QVariantMap &request) = 0;

protected:
    bool m_connected;
    void setConnected(const bool &connected);

signals:
    void dataReady(const QVariantMap &data);
    void connectedChanged(const bool &connected);

public slots:
    virtual void enable() { }
    virtual void disable() { }

};

#endif // GUHINTERFACE_H
