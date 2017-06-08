#ifndef NETWORKMANAGERHANDLER_H
#define NETWORKMANAGERHANDLER_H

#include <QObject>

#include "jsonhandler.h"

class NetworkManagerHandler : public JsonHandler
{
    Q_OBJECT
public:
    explicit NetworkManagerHandler(QObject *parent = 0);

    QString nameSpace() const;

    Q_INVOKABLE void processWirelessNetworkDeviceChanged(const QVariantMap &params);

signals:

public slots:
};

#endif // NETWORKMANAGERHANDLER_H
