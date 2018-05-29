#ifndef EVENTDESCRIPTORPARAMSFILTERMODEL_H
#define EVENTDESCRIPTORPARAMSFILTERMODEL_H

#include <QSortFilterProxyModel>

class EventDescriptor;
class ParamDescriptor;

class EventDescriptorParamsFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
//    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(EventDescriptor* eventDescriptor READ eventDescriptor WRITE setEventDescriptor NOTIFY eventDescriptorChanged)
    Q_PROPERTY(QVariant::Type type READ type WRITE setType NOTIFY typeChanged)

public:
    explicit EventDescriptorParamsFilterModel(QObject *parent = nullptr);

//    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
//    QVariant data(const QModelIndex &index, int role) const override;

    EventDescriptor* eventDescriptor() const;
    void setEventDescriptor(EventDescriptor* eventDescriptor);

    QVariant::Type type() const;
    void setType(QVariant::Type type);

    Q_INVOKABLE ParamDescriptor* get(int idx) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void eventDescriptorChanged();
    void typeChanged();

public slots:

private:
    EventDescriptor* m_eventDescriptor = nullptr;
    QVariant::Type m_type;
};

#endif // EVENTDESCRIPTORPARAMSFILTERMODEL_H
