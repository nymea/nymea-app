#ifndef PLATFORMHELPERGENERIC_H
#define PLATFORMHELPERGENERIC_H

#include <QObject>
#include "platformhelper.h"
#include "raspberrypihelper.h"

class PlatformHelperGeneric : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperGeneric(QObject *parent = nullptr);

    Q_INVOKABLE virtual void requestPermissions() override;

    Q_INVOKABLE virtual void hideSplashScreen() override;

    virtual bool hasPermissions() const override;
    virtual QString machineHostname() const override;
    virtual QString device() const override;
    virtual QString deviceSerial() const override;
    virtual QString deviceModel() const override;
    virtual QString deviceManufacturer() const override;

    virtual bool canControlScreen() const override;
    virtual int screenTimeout() const override;
    virtual void setScreenTimeout(int timeout) override;
    virtual int screenBrightness() const override;
    virtual void setScreenBrightness(int percent) override;

    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbyckType) override;

private:
    RaspberryPiHelper *m_piHelper = nullptr;
};

#endif // PLATFORMHELPERGENERIC_H
