#ifndef DEVICECONTROLAPPLICATION_H
#define DEVICECONTROLAPPLICATION_H

#include <QApplication>
#include <QNearFieldManager>
#include <QNdefMessage>
#include <QQmlApplicationEngine>
#include <QNdefMessage>

#include "types/ruleactions.h"
#include "connection/discovery/nymeadiscovery.h"
#include "engine.h"

class DeviceControlApplication : public QApplication
{
    Q_OBJECT
public:
    explicit DeviceControlApplication(int argc, char *argv[]);

private slots:
    void handleNdefMessage(QNdefMessage message,QNearFieldTarget* target);

    void connectToNymea(const QUuid &nymeaId);

    void runNfcAction();

private:
    NymeaDiscovery *m_discovery = nullptr;
    Engine *m_engine = nullptr;
    QQmlApplicationEngine *m_qmlEngine = nullptr;

    QUrl m_pendingNfcAction;


};

#endif // DEVICECONTROLAPPLICATION_H
