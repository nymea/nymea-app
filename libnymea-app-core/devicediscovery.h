#ifndef DEVICEDISCOVERY_H
#define DEVICEDISCOVERY_H

#include <QAbstractListModel>
#include <QUuid>

#include "engine.h"

class DeviceDescriptor: public QObject {
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(Params* params READ params CONSTANT)
public:
    DeviceDescriptor(const QUuid &id, const QString &name, const QString &description, QObject *parent = nullptr);

    QUuid id() const;
    QString name() const;
    QString description() const;
    Params* params() const;

private:
    QUuid m_id;
    QString m_name;
    QString m_description;
    Params *m_params = nullptr;
};

class DeviceDiscovery : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine)
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

    Q_INVOKABLE DeviceDescriptor* get(int index) const;

    Engine* engine() const;
    void setEngine(Engine *jsonRpcClient);

    bool busy() const;

private slots:
    void discoverDevicesResponse(const QVariantMap &params);

signals:
    void busyChanged();
    void countChanged();
    void engineChanged();

private:
    Engine *m_engine = nullptr;
    bool m_busy = false;

    bool contains(const QUuid &deviceDescriptorId) const;
    QList<DeviceDescriptor*> m_foundDevices;
};

#endif // DEVICEDISCOVERY_H
