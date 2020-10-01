#ifndef NYMEAAPPSERVICE_H
#define NYMEAAPPSERVICE_H

#include <QAndroidService>
#include <QNearFieldManager>
#include <QNdefMessage>

#include "engine.h"

class NymeaAppService : public QAndroidService
{
    Q_OBJECT
public:
    explicit NymeaAppService(int argc, char** argv);

    QHash<QUuid, Engine*> engines() const;

private:
    void sendNotification(const QString &notification, const QVariantMap &params);


private:
    QHash<QUuid, Engine*> m_engines;

};

#endif // NYMEAAPPSERVICE_H
