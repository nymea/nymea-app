#ifndef PRIVACYPOLICYHELPER_H
#define PRIVACYPOLICYHELPER_H

#include <QObject>
#include <qqml.h>

class PrivacyPolicyHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int version READ version CONSTANT)
    Q_PROPERTY(QString text READ text CONSTANT)
public:
    explicit PrivacyPolicyHelper(QObject *parent = nullptr);
    static QObject *qmlProvider(QQmlEngine *engine, QJSEngine *scriptEngine);


    int version() const;
    QString text() const;

private:
    QString findFile() const;

    int m_version = -1;
};

#endif // PRIVACYPOLICYHELPER_H
