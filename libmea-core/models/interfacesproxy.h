#ifndef INTERFACESPROXY_H
#define INTERFACESPROXY_H

#include <QSortFilterProxyModel>

class Devices;
class Interface;
class Interfaces;

class InterfacesProxy: public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(Devices* devicesFilter READ devicesFilter WRITE setDevicesFilter NOTIFY devicesFilterChanged)
    Q_PROPERTY(bool showEvents READ showEvents WRITE setShowEvents NOTIFY showEventsChanged)
    Q_PROPERTY(bool showActions READ showActions WRITE setShowActions NOTIFY showActionsChanged)
    Q_PROPERTY(bool showStates READ showStates WRITE setShowStates NOTIFY showStatesChanged)

public:
    InterfacesProxy(QObject *parent = nullptr);

    QStringList shownInterfaces() const { return m_shownInterfaces; }
    void setShownInterfaces(const QStringList &shownInterfaces) { m_shownInterfaces = shownInterfaces; emit shownInterfacesChanged(); invalidateFilter(); }

    Devices* devicesFilter() const { return m_devicesFilter; }
    void setDevicesFilter(Devices *devices) { m_devicesFilter = devices; emit devicesFilterChanged(); invalidateFilter(); }

    bool showEvents() const;
    void setShowEvents(bool showEvents);

    bool showActions() const;
    void setShowActions(bool showActions);

    bool showStates() const;
    void setShowStates(bool showStates);

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    Q_INVOKABLE Interface* get(int index) const;

signals:
    void shownInterfacesChanged();
    void devicesFilterChanged();
    void showEventsChanged();
    void showActionsChanged();
    void showStatesChanged();

private:
    Interfaces *m_interfaces = nullptr;
    QStringList m_shownInterfaces;
    Devices* m_devicesFilter = nullptr;
    bool m_showEvents = false;
    bool m_showActions = false;
    bool m_showStates = false;
};

#endif // INTERFACESPROXY_H
