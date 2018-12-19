#ifndef PLATFORMHELPERANDROID_H
#define PLATFORMHELPERANDROID_H

#include <QObject>
#include "platformhelper.h"
#include <QtAndroid>

class PlatformHelperAndroid : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperAndroid(QObject *parent = nullptr);

    Q_INVOKABLE void requestPermissions() override;

    bool hasPermissions() const override;
    QString machineHostname() const override;
    QString deviceSerial() const override;
    QString deviceModel() const override;
    QString deviceManufacturer() const override;

private:
    static void permissionRequestFinished(const QtAndroid::PermissionResultMap &);

};

#endif // PLATFORMHELPERANDROID_H
