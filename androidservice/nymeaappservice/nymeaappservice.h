#ifndef NYMEAAPPSERVICE_H
#define NYMEAAPPSERVICE_H

#include <QCoreApplication>
#include <QHash>
#include <QNearFieldManager>
#include <QNdefMessage>
#include <QUuid>
#include <QVariantMap>

#include "engine.h"
#include "androidbinder.h"

class NymeaAppService : public QCoreApplication
{
    Q_OBJECT
public:
    explicit NymeaAppService(int argc, char** argv);
    ~NymeaAppService() override;

    QHash<QUuid, Engine*> engines() const;

    QString handleBinderRequest(const QString &payload);

    static NymeaAppService *instance();

private:
    void sendNotification(const QString &notification, const QVariantMap &params);


private:
    static NymeaAppService *s_instance;

    QHash<QUuid, Engine*> m_engines;
    AndroidBinder m_binder;

};

#endif // NYMEAAPPSERVICE_H
