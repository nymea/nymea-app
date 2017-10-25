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
        RoleName
    };
    explicit EventDescriptors(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    EventDescriptor* get(int index) const;

    void addEventDescriptor(EventDescriptor *eventDescriptor);

signals:
    void countChanged();

private:
    QList<EventDescriptor*> m_list;
};

#endif // EVENTDESCRIPTORS_H
