#ifndef EVENTDESCRIPTOR_H
#define EVENTDESCRIPTOR_H

#include <QObject>
#include <QUuid>

class EventDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QUuid eventTypeId READ eventTypeId CONSTANT)

public:
    explicit EventDescriptor(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid eventTypeId() const;
    void setEventTypeId(const QUuid &eventTypeId);

signals:

private:
    QUuid m_deviceId;
    QUuid m_eventTypeId;
};

#endif // EVENTDESCRIPTOR_H
