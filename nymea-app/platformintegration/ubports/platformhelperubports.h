#ifndef PLATFORMHELPERUBPORTS_H
#define PLATFORMHELPERUBPORTS_H

#include <QObject>

#include "platformhelper.h"

class UriHandlerObject: public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Application")

 public:
    UriHandlerObject(PlatformHelper* platformHelper);

 public Q_SLOTS:
    void Open(const QStringList& uris, const QHash<QString, QVariant>& platformData);

 private:
    PlatformHelper* m_platformHelper = nullptr;
};


class PlatformHelperUBPorts : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperUBPorts(QObject *parent = nullptr);

    QString platform() const override;
    QString deviceSerial() const override;

signals:

private:
    void setupUriHandler();

    UriHandlerObject m_uriHandlerObject;

};

#endif // PLATFORMHELPERUBPORTS_H
