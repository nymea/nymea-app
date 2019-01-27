#ifndef PLATFORMHELPERGENERIC_H
#define PLATFORMHELPERGENERIC_H

#include <QObject>
#include "platformhelper.h"

class PlatformHelperGeneric : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperGeneric(QObject *parent = nullptr);

    Q_INVOKABLE virtual void requestPermissions() override;

    virtual bool hasPermissions() const override;
    virtual QString machineHostname() const override;
    virtual QString deviceSerial() const override;
    virtual QString deviceModel() const override;
    virtual QString deviceManufacturer() const override;

    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbyckType) override;
signals:

public slots:
};

#endif // PLATFORMHELPERGENERIC_H
