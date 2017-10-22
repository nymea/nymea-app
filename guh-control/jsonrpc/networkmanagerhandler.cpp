#include "networkmanagerhandler.h"

#include <QDebug>

NetworkManagerHandler::NetworkManagerHandler(QObject *parent) :
    JsonHandler(parent)
{

}

QString NetworkManagerHandler::nameSpace() const
{
    return "NetworkManager";
}

void NetworkManagerHandler::processWirelessNetworkDeviceChanged(const QVariantMap &params)
{
    Q_UNUSED(params);
}
