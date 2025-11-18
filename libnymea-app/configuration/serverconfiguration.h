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

#ifndef SERVERCONFIGURATION_H
#define SERVERCONFIGURATION_H

#include <QObject>
#include <QHostAddress>
#include <QUuid>

class ServerConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY addressChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool authenticationEnabled READ authenticationEnabled WRITE setAuthenticationEnabled NOTIFY authenticationEnabledChanged)
    Q_PROPERTY(bool sslEnabled READ sslEnabled WRITE setSslEnabled NOTIFY sslEnabledChanged)

public:
    explicit ServerConfiguration(const QString &id, const QString &address = QString(), int port = 0, bool authEnabled = false, bool sslEnabled = false, QObject *parent = nullptr);
    virtual ~ServerConfiguration();

    QString id() const;

    QString address() const;
    void setAddress(const QString &address);

    int port() const;
    void setPort(int port);

    bool authenticationEnabled() const;
    void setAuthenticationEnabled(bool authenticationEnabled);

    bool sslEnabled() const;
    void setSslEnabled(bool sslEnabled);

    Q_INVOKABLE virtual ServerConfiguration* clone() const;

signals:
    void addressChanged();
    void portChanged();
    void authenticationEnabledChanged();
    void sslEnabledChanged();

private:
    QString m_id;
    QString m_hostAddress;
    int m_port;
    bool m_authEnabled;
    bool m_sslEnabled;
};

class WebServerConfiguration: public ServerConfiguration
{
    Q_OBJECT
    Q_PROPERTY(QString publicFolder READ publicFolder WRITE setPublicFolder NOTIFY publicFolderChanged)
public:
    explicit WebServerConfiguration(const QString &id, const QString &address = QString(), int port = 0, bool authEnabled = false, bool sslEnabled = false, QObject *parent = nullptr)
        : ServerConfiguration(id, address, port, authEnabled, sslEnabled, parent) {}

    QString publicFolder() const;
    void setPublicFolder(const QString &publicFolder);

    Q_INVOKABLE ServerConfiguration* clone() const override;

signals:
    void publicFolderChanged();

private:
    QString m_publicFolder;
};

class TunnelProxyServerConfiguration: public ServerConfiguration
{
    Q_OBJECT
    Q_PROPERTY(bool ignoreSslErrors READ ignoreSslErrors WRITE setIgnoreSslErrors NOTIFY ignoreSslErrorsChanged)
public:
    explicit TunnelProxyServerConfiguration(const QString &id, const QString &address = QString(), int port = 0, bool authenticationEnabled = false, bool sslEnabled = false, bool ignoreSslErrors = false, QObject *parent = nullptr)
        : ServerConfiguration(id, address, port, authenticationEnabled, sslEnabled, parent),
          m_ignoreSslErrors(ignoreSslErrors) {}

    bool ignoreSslErrors() const;
    void setIgnoreSslErrors(bool ignoreSslErrors);

    Q_INVOKABLE ServerConfiguration* clone() const override;

signals:
    void ignoreSslErrorsChanged();

private:
    bool m_ignoreSslErrors = false;
};

#endif // SERVERCONFIGURATION_H
