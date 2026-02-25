#ifndef NYMEAHOSTSFILTERMODEL_H
#define NYMEAHOSTSFILTERMODEL_H

#include <QSortFilterProxyModel>

#include "jsonrpc/jsonrpcclient.h"
#include "connection/discovery/nymeadiscovery.h"

class NymeaHostsFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(NymeaDiscovery* discovery READ discovery WRITE setDiscovery NOTIFY discoveryChanged)
    Q_PROPERTY(JsonRpcClient* jsonRpcClient READ jsonRpcClient WRITE setJsonRpcClient NOTIFY jsonRpcClientChanged)
    Q_PROPERTY(bool showUnreachableBearers READ showUnreachableBearers WRITE setShowUnreachableBearers NOTIFY showUnreachableBearersChanged)
    Q_PROPERTY(bool showUnreachableHosts READ showUnreachableHosts WRITE setShowUnreachableHosts NOTIFY showUnreachableHostsChanged)

public:
    NymeaHostsFilterModel(QObject *parent = nullptr);

    NymeaDiscovery* discovery() const;
    void setDiscovery(NymeaDiscovery *discovery);

    JsonRpcClient* jsonRpcClient() const;
    void setJsonRpcClient(JsonRpcClient* jsonRpcClient);

    bool showUnreachableBearers() const;
    void setShowUnreachableBearers(bool showUnreachableBearers);

    bool showUnreachableHosts() const;
    void setShowUnreachableHosts(bool showUnreachableHosts);

    Q_INVOKABLE NymeaHost* get(int index) const;

signals:
    void countChanged();
    void discoveryChanged();
    void jsonRpcClientChanged();
    void showUnreachableBearersChanged();
    void showUnreachableHostsChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    NymeaDiscovery *m_nymeaDiscovery = nullptr;
    JsonRpcClient *m_jsonRpcClient = nullptr;

    bool m_showUneachableBearers = false;
    bool m_showUneachableHosts = false;

};

#endif // NYMEAHOSTSFILTERMODEL_H
