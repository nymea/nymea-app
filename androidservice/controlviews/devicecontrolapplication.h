#ifndef DEVICECONTROLAPPLICATION_H
#define DEVICECONTROLAPPLICATION_H

#include <QApplication>
#include <QNearFieldManager>
#include <QNdefMessage>

#include "connection/discovery/nymeadiscovery.h"
#include "engine.h"

class DeviceControlApplication : public QApplication
{
    Q_OBJECT
public:
    explicit DeviceControlApplication(int argc, char *argv[]);

private slots:
    void handleNdefMessage(QNdefMessage message,QNearFieldTarget* target);

    void createView();

private:
    NymeaDiscovery *m_discovery = nullptr;
    Engine *m_engine = nullptr;

};

#endif // DEVICECONTROLAPPLICATION_H
