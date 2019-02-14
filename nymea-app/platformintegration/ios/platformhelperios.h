#ifndef PLATFORMHELPERIOS_H
#define PLATFORMHELPERIOS_H

#include <QObject>

#include "platformhelper.h"

class PlatformHelperIOS : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperIOS(QObject *parent = nullptr);

    Q_INVOKABLE virtual void requestPermissions() override;

    Q_INVOKABLE void hideSplashScreen() override;

    virtual bool hasPermissions() const override;
    virtual QString machineHostname() const override;
    virtual QString device() const override;
    virtual QString deviceSerial() const override;
    virtual QString deviceModel() const override;
    virtual QString deviceManufacturer() const override;

    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbackType) override;

private:
    // defined in platformhelperios.mm
    QString readKeyChainEntry(const QString &service, const QString &key);
    void writeKeyChainEntry(const QString &service, const QString &key, const QString &value);

    void generateSelectionFeedback();
    void generateImpactFeedback();
    void generateNotificationFeedback();
};

#endif // PLATFORMHELPERIOS_H
