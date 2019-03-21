#ifndef SERVERCONFIGURATIONS_H
#define SERVERCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "serverconfiguration.h"

class ServerConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleId,
        RoleAddress,
        RolePort,
        RoleAuthenticationEnabled,
        RoleSslEnabled
    };
    Q_ENUM(Roles)

    explicit ServerConfigurations(QObject *parent = nullptr);
    virtual ~ServerConfigurations() override = default;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addConfiguration(ServerConfiguration *configuration);
    void removeConfiguration(const QString &id);

    void clear();

    Q_INVOKABLE virtual ServerConfiguration* get(int index) const;

signals:
    void countChanged();

protected:
    QList<ServerConfiguration*> m_list;
};


class WebServerConfigurations: public ServerConfigurations
{
    Q_OBJECT
public:
    WebServerConfigurations(QObject *parent = nullptr): ServerConfigurations(parent) {}

    Q_INVOKABLE WebServerConfiguration* getWebServerConfiguration(int index) const {
        return dynamic_cast<WebServerConfiguration*>(m_list.at(index));
    }
};

#endif // SERVERCONFIGURATIONS_H
