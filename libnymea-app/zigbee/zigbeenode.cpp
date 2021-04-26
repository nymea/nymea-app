#include "zigbeenode.h"

ZigbeeNode::ZigbeeNode(QUuid networkUuid, QObject *parent) :
    QObject(parent),
    m_networkUuid(networkUuid)
{

}

QUuid ZigbeeNode::networkUuid() const
{
    return m_networkUuid;
}
