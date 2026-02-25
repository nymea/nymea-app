#include "nymeahostsfiltermodel.h"

#include "jsonrpc/jsonrpcclient.h"

NymeaHostsFilterModel::NymeaHostsFilterModel(QObject *parent):
    QSortFilterProxyModel(parent)
{

}

NymeaDiscovery *NymeaHostsFilterModel::discovery() const
{
    return m_nymeaDiscovery;
}

void NymeaHostsFilterModel::setDiscovery(NymeaDiscovery *discovery)
{
    if (m_nymeaDiscovery != discovery) {
        m_nymeaDiscovery = discovery;
        setSourceModel(discovery->nymeaHosts());
        emit discoveryChanged();

        connect(discovery->nymeaHosts(), &NymeaHosts::hostChanged, this, [this](){
//            qDebug() << "Host Changed!";
            invalidateFilter();
            emit countChanged();
        });

        emit countChanged();
    }
}

JsonRpcClient *NymeaHostsFilterModel::jsonRpcClient() const
{
    return m_jsonRpcClient;
}

void NymeaHostsFilterModel::setJsonRpcClient(JsonRpcClient *jsonRpcClient)
{
    if (m_jsonRpcClient != jsonRpcClient) {
        m_jsonRpcClient = jsonRpcClient;
        emit jsonRpcClientChanged();

        connect(m_jsonRpcClient, &JsonRpcClient::availableBearerTypesChanged, this, [this](){
//            qDebug() << "Bearer Types Changed!";
            invalidateFilter();
            emit countChanged();
        });

        invalidateFilter();
        emit countChanged();
    }
}

bool NymeaHostsFilterModel::showUnreachableBearers() const
{
    return m_showUneachableBearers;
}

void NymeaHostsFilterModel::setShowUnreachableBearers(bool showUnreachableBearers)
{
    if (m_showUneachableBearers != showUnreachableBearers) {
        m_showUneachableBearers = showUnreachableBearers;
        emit showUnreachableBearersChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool NymeaHostsFilterModel::showUnreachableHosts() const
{
    return m_showUneachableHosts;
}

void NymeaHostsFilterModel::setShowUnreachableHosts(bool showUnreachableHosts)
{
    if (m_showUneachableHosts != showUnreachableHosts) {
        m_showUneachableHosts = showUnreachableHosts;
        emit showUnreachableHostsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

NymeaHost *NymeaHostsFilterModel::get(int index) const
{
    return m_nymeaDiscovery->nymeaHosts()->get(mapToSource(this->index(index, 0)).row());
}

bool NymeaHostsFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    NymeaHost *host = m_nymeaDiscovery->nymeaHosts()->get(sourceRow);
    if (m_jsonRpcClient && !m_showUneachableBearers) {
        bool hasReachableConnection = false;
        for (int i = 0; i < host->connections()->rowCount(); i++) {
//            qDebug() << "checking host for available bearer" << host->name() << host->connections()->get(i)->url() << "available bearer types:" << m_nymeaConnection->availableBearerTypes() << "hosts bearer types" << host->connections()->get(i)->bearerType();
            // Either enable a connection when the Bearer type is directly available
            switch (host->connections()->get(i)->bearerType()) {
            case Connection::BearerTypeLan:
                hasReachableConnection |= m_jsonRpcClient->availableBearerTypes().testFlag(NymeaConnection::BearerTypeEthernet);
                hasReachableConnection |= m_jsonRpcClient->availableBearerTypes().testFlag(NymeaConnection::BearerTypeWiFi);
                break;
            case Connection::BearerTypeWan:
            case Connection::BearerTypeCloud:
                hasReachableConnection |= m_jsonRpcClient->availableBearerTypes().testFlag(NymeaConnection::BearerTypeEthernet);
                hasReachableConnection |= m_jsonRpcClient->availableBearerTypes().testFlag(NymeaConnection::BearerTypeWiFi);
                hasReachableConnection |= m_jsonRpcClient->availableBearerTypes().testFlag(NymeaConnection::BearerTypeMobileData);
                break;
            case Connection::BearerTypeBluetooth:
                hasReachableConnection |= m_jsonRpcClient->availableBearerTypes().testFlag(NymeaConnection::BearerTypeBluetooth);
                break;
            case Connection::BearerTypeUnknown:
            case Connection::BearerTypeLoopback:
                hasReachableConnection = true;
                break;
            case Connection::BearerTypeNone:
                break;
            }
        }
        if (!hasReachableConnection) {
            return false;
        }
    }
    if (!m_showUneachableHosts) {
        bool isOnline = false;
        for (int i = 0; i < host->connections()->rowCount(); i++) {
            if (host->connections()->get(i)->online()) {
                isOnline = true;
                break;
            }
        }
        if (!isOnline) {
            return false;
        }
    }
    return true;
}
