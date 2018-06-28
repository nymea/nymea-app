#ifndef INTERFACESMODEL_H
#define INTERFACESMODEL_H

#include <QObject>
#include <QAbstractListModel>

#include "devices.h"

class InterfacesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Devices* devices READ devices WRITE setDevices NOTIFY devicesChanged)
    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(bool showUncategorized READ showUncategorized WRITE setShowUncategorized NOTIFY showUncategorizedChanged)

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

    bool showUncategorized() const;
    void setShowUncategorized(bool showUncategorized);

signals:
    void countChanged();
    void devicesChanged();
    void shownInterfacesChanged();
    void showUncategorizedChanged();

private slots:
    void syncInterfaces();
    void rowsChanged(const QModelIndex &index, int first, int last);

private:
    Devices *m_devices = nullptr;
    QStringList m_interfaces;

    QStringList m_shownInterfaces;
    bool m_showUncategorized = false;
};

class InterfacesSortModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(InterfacesModel* interfacesModel READ interfacesModel WRITE setInterfacesModel NOTIFY interfacesModelChanged)

public:
    InterfacesSortModel(QObject *parent = nullptr);

    InterfacesModel* interfacesModel() const;
    void setInterfacesModel(InterfacesModel* interfacesModel);

    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;

signals:
    void interfacesModelChanged();

private:
    InterfacesModel* m_interfacesModel = nullptr;
};

#endif // INTERFACESMODEL_H
