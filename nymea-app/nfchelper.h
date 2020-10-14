#ifndef NFCHELPER_H
#define NFCHELPER_H

#include <QObject>
#include <QQmlEngine>

class NfcHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAvailable READ isAvailable CONSTANT)

public:
    static NfcHelper* instance();
    static QObject *nfcHelperProvider(QQmlEngine *engine, QJSEngine *scriptEngine);


    bool isAvailable() const;

private:
    explicit NfcHelper(QObject *parent = nullptr);
};

#endif // NFCHELPER_H
