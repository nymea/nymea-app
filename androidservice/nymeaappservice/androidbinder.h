#ifndef ANDROIDBINDER_H
#define ANDROIDBINDER_H

#include <QAndroidBinder>

#include "nymeaappservice.h"
#include "engine.h"

class AndroidBinder : public QAndroidBinder
{
public:
    explicit AndroidBinder(NymeaAppService *service);

    bool onTransact(int code, const QAndroidParcel &data, const QAndroidParcel &reply, QAndroidBinder::CallType flags) override;

private:
    void sendReply(const QAndroidParcel &reply, const QVariantMap &params);

private:
    NymeaAppService *m_service = nullptr;
};

#endif // ANDROIDBINDER_H
