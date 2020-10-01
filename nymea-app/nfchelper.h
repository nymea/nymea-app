#ifndef NFCHELPER_H
#define NFCHELPER_H

#include <QObject>
#include <QNearFieldManager>
#include <QNdefMessage>

#include "types/device.h"
#include "engine.h"

class NfcHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit NfcHelper(QObject *parent = nullptr);

    bool busy() const;

public slots:
    void writeThingStates(Engine *engine, Device *thing);

signals:
    void busyChanged();

private slots:
    void targetDetected(QNearFieldTarget *target);
    void targetLost(QNearFieldTarget *target);

    void ndefMessageWritten();
    void targetError();

private:
    QNearFieldManager *m_manager = nullptr;
    bool m_busy = false;

    QNdefMessage m_currentMessage;

};

#endif // NFCHELPER_H
