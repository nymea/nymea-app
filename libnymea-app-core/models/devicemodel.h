#ifndef DEVICEMODEL_H
#define DEVICEMODEL_H

#include <QObject>

#include "types/device.h"
#include "types/deviceclass.h"

class DeviceModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_PROPERTY(Device* device READ device WRITE setDevice NOTIFY deviceChanged)

    Q_PROPERTY(bool showStates READ showStates WRITE setShowStates NOTIFY showStatesChanged)
    Q_PROPERTY(bool showActions READ showActions WRITE setShowActions NOTIFY showActionsChanged)
    Q_PROPERTY(bool showEvents READ showEvents WRITE setShowEvents NOTIFY showEventsChanged)

public:
    enum Roles {
        RoleId,
        RoleType,
        RoleDisplayName,
        RoleWritable
    };
    Q_ENUM(Roles)
    enum Type {
        TypeStateType,
        TypeActionType,
        TypeEventType
    };
    Q_ENUM(Type)

    explicit DeviceModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariant getData(int index, int role) const;

    Device* device() const;
    void setDevice(Device *device);

    bool showStates() const;
    void setShowStates(bool showStates);

    bool showActions() const;
    void setShowActions(bool showActions);

    bool showEvents() const;
    void setShowEvents(bool showEvents);

signals:
    void deviceChanged();

    void countChanged();

    bool showStatesChanged();
    bool showActionsChanged();
    bool showEventsChanged();

private:
    void updateList();

private:
    Device *m_device = nullptr;

    bool m_showStates = true;
    bool m_showActions = true;
    bool m_showEvents = true;

    QList<QUuid> m_list;
};

#endif // DEVICEMODEL_H
