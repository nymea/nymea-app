#ifndef EVENTDESCRIPTORTEMPLATE_H
#define EVENTDESCRIPTORTEMPLATE_H

#include <QObject>
#include "types/paramdescriptors.h"

class EventDescriptorTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString interfaceName READ interfaceName CONSTANT)
    Q_PROPERTY(QString interfaceEvent READ interfaceEvent CONSTANT)
    Q_PROPERTY(int selectionId READ selectionId CONSTANT)
    Q_PROPERTY(SelectionMode selectionMode READ selectionMode CONSTANT)
    Q_PROPERTY(ParamDescriptors* paramDescriptors READ paramDescriptors CONSTANT)
public:
    enum SelectionMode {
        SelectionModeAny,
        SelectionModeDevice,
        SelectionModeInterface,
    };
    Q_ENUM(SelectionMode)

    explicit EventDescriptorTemplate(const QString &interfaceName, const QString &interfaceEvent, int selectionId, SelectionMode selectionMode = SelectionModeAny, QObject *parent = nullptr);

    QString interfaceName() const;
    QString interfaceEvent() const;
    int selectionId() const;
    SelectionMode selectionMode() const;
    ParamDescriptors* paramDescriptors() const;

private:
    QString m_interfaceName;
    QString m_interfaceEvent;
    int m_selectionId = 0;
    SelectionMode m_selectionMode = SelectionModeAny;
    ParamDescriptors *m_paramDescriptors = nullptr;
};

#include <QAbstractListModel>

class EventDescriptorTemplates: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
public:
    EventDescriptorTemplates(QObject *parent = nullptr): QAbstractListModel(parent) {}

    QStringList interfaces() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { Q_UNUSED(parent); return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override { Q_UNUSED(index); Q_UNUSED(role); return QVariant(); }

    void addEventDescriptorTemplate(EventDescriptorTemplate *eventDescriptorTemplate) {
        eventDescriptorTemplate->setParent(this);
        beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
        m_list.append(eventDescriptorTemplate);
        endInsertRows();
        emit countChanged();
    }

    Q_INVOKABLE EventDescriptorTemplate* get(int index) const {
        if (index < 0 || index >= m_list.count()) {
            return nullptr;
        }
        return m_list.at(index);
    }



signals:
    void countChanged();

private:
    QList<EventDescriptorTemplate*> m_list;
};
#endif // EVENTDESCRIPTORTEMPLATE_H
