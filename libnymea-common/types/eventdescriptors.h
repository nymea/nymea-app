#ifndef EVENTDESCRIPTORS_H
#define EVENTDESCRIPTORS_H

#include <QAbstractListModel>

class EventDescriptor;

class EventDescriptors : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleDeviceId,
        RoleEventTypeId
    };
    explicit EventDescriptors(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE EventDescriptor* get(int index) const;

    Q_INVOKABLE EventDescriptor* createNewEventDescriptor();
    Q_INVOKABLE void addEventDescriptor(EventDescriptor *eventDescriptor);
    Q_INVOKABLE void removeEventDescriptor(int index);

    bool operator==(EventDescriptors* other) const;

signals:
    void countChanged();

private:
    QList<EventDescriptor*> m_list;
};

#endif // EVENTDESCRIPTORS_H
