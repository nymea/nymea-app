#ifndef ANDROIDBINDER_H
#define ANDROIDBINDER_H

#include <QString>
#include <QVariantMap>

class NymeaAppService;

class AndroidBinder
{
public:
    explicit AndroidBinder(NymeaAppService *service);

    QString handleTransact(const QString &payload, bool *handled);

private:
    QString buildReply(const QVariantMap &params) const;

private:
    NymeaAppService *m_service = nullptr;
};

#endif // ANDROIDBINDER_H
