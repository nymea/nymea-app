#ifndef INTERFACESMODEL_H
#define INTERFACESMODEL_H

#include <QObject>
#include <QAbstractListModel>

#include "devices.h"

class InterfacesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Devices* devices READ devices WRITE setDevices NOTIFY devicesChanged)
    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)

public:
    enum Roles {
        RoleName
    };
    Q_ENUMS(Roles)

    explicit InterfacesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Devices* devices() const;
    void setDevices(Devices *devices);

    QStringList shownInterfaces() const;
    void setShownInterfaces(const QStringList &shownInterfaces);

signals:
    void devicesChanged();
    void shownInterfacesChanged();

private slots:
    void syncInterfaces();
    void rowsChanged(const QModelIndex &index, int first, int last);

private:
    Devices *m_devices = nullptr;
    QStringList m_interfaces;

    QStringList m_shownInterfaces;
};

#endif // INTERFACESMODEL_H
