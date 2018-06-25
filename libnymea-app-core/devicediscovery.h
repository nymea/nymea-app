#ifndef DEVICEDISCOVERY_H
#define DEVICEDISCOVERY_H

#include <QAbstractListModel>
#include <QUuid>

class DeviceDiscovery : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleId,
        RoleName,
        RoleDescription
    };

    DeviceDiscovery(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;


    Q_INVOKABLE void discoverDevices(const QUuid &deviceClassId, const QVariantList &discoveryParams = {});

    bool busy() const;

private slots:
    void discoverDevicesResponse(const QVariantMap &params);

signals:
    void busyChanged();
    void countChanged();

private:
    class DeviceDescriptor {
    public:
        DeviceDescriptor(const QUuid &id, const QString &name, const QString &description): m_id(id), m_name(name), m_description(description) {}
        QUuid m_id;
        QString m_name;
        QString m_description;
    };

    bool m_busy = false;

    bool contains(const QUuid &deviceDescriptorId) const;
    QList<DeviceDescriptor> m_foundDevices;
};

#endif // DEVICEDISCOVERY_H
