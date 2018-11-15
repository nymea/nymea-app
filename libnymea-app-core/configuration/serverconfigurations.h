#ifndef SERVERCONFIGURATIONS_H
#define SERVERCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

class ServerConfiguration;

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

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addConfiguration(ServerConfiguration *configuration);
    void removeConfiguration(const QString &id);

    void clear();

    Q_INVOKABLE ServerConfiguration* get(int index) const;

signals:
    void countChanged();

private:
    QList<ServerConfiguration*> m_list;
};

#endif // SERVERCONFIGURATIONS_H
