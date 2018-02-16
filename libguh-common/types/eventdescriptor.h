#ifndef EVENTDESCRIPTOR_H
#define EVENTDESCRIPTOR_H

#include <QObject>
#include <QUuid>

#include "paramdescriptors.h"

class EventDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QUuid eventTypeId READ eventTypeId WRITE setEventTypeId NOTIFY eventTypeIdChanged)

    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceEvent READ interfaceEvent CONSTANT)

    Q_PROPERTY(ParamDescriptors* paramDescriptors READ paramDescriptors CONSTANT)

public:
    explicit EventDescriptor(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid eventTypeId() const;
    void setEventTypeId(const QUuid &eventTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceEvent() const;
    void setInterfaceEvent(const QString &interfaceEvent);

    ParamDescriptors* paramDescriptors() const;

signals:
    void deviceIdChanged();
    void eventTypeIdChanged();
    void interfaceNameChanged();

private:
    QUuid m_deviceId;
    QUuid m_eventTypeId;

    QString m_interfaceName;
    QString m_interfaceEvent;

    ParamDescriptors *m_paramDescriptors;
};

#endif // EVENTDESCRIPTOR_H
