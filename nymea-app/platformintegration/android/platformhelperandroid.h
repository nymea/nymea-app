#ifndef PLATFORMHELPERANDROID_H
#define PLATFORMHELPERANDROID_H

#include <QObject>
#include "platformhelper.h"
#include <QtAndroid>

class PlatformHelperAndroid : public PlatformHelper
{
    Q_OBJECT
public:
    enum Theme { Light, Dark };

    explicit PlatformHelperAndroid(QObject *parent = nullptr);

    Q_INVOKABLE void requestPermissions() override;

    Q_INVOKABLE void hideSplashScreen() override;

    bool hasPermissions() const override;
    QString machineHostname() const override;
    QString deviceSerial() const override;
    QString device() const override;
    QString deviceModel() const override;
    QString deviceManufacturer() const override;

    Q_INVOKABLE void vibrate(HapticsFeedback feedbackType) override;

    void setTopPanelColor(const QColor &color) override;
    void setTopPanelTheme(Theme theme);
    void setBottomPanelColor(const QColor &color) override;

private:
    static void permissionRequestFinished(const QtAndroid::PermissionResultMap &);

};

#endif // PLATFORMHELPERANDROID_H
