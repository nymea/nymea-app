#include "nfchelper.h"

#include <QNearFieldManager>

NfcHelper::NfcHelper(QObject *parent) : QObject(parent)
{

}

NfcHelper *NfcHelper::instance()
{
    static NfcHelper *thiz = nullptr;
    if (!thiz) {
        thiz = new NfcHelper();
    }
    return thiz;
}

QObject *NfcHelper::nfcHelperProvider(QQmlEngine */*engine*/, QJSEngine */*scriptEngine*/)
{
    return instance();
}

bool NfcHelper::isAvailable() const
{
    QNearFieldManager manager;
#if  QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    return manager.isAvailable();
#else
    return manager.isEnabled();
#endif
}
