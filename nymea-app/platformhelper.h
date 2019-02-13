#ifndef PLATFORMHELPER_H
#define PLATFORMHELPER_H

#include <QObject>
#include <QQuickWindow>

class PlatformHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasPermissions READ hasPermissions NOTIFY permissionsRequestFinished)
    Q_PROPERTY(QString deviceSerial READ deviceSerial CONSTANT)
    Q_PROPERTY(QString deviceModel READ deviceModel CONSTANT)
    Q_PROPERTY(QString deviceManufacturer READ deviceManufacturer CONSTANT)
    Q_PROPERTY(QString machineHostname READ machineHostname CONSTANT)

public:
    enum HapticsFeedback {
        HapticsFeedbackSelection,
        HapticsFeedbackImpact,
        HapticsFeedbackNotification
    };
    Q_ENUM(HapticsFeedback)

    explicit PlatformHelper(QObject *parent = nullptr);
    virtual ~PlatformHelper() = default;

    Q_INVOKABLE virtual void requestPermissions() = 0;

    Q_INVOKABLE virtual void hideSplashScreen() = 0;

    virtual bool hasPermissions() const = 0;
    virtual QString machineHostname() const = 0;
    virtual QString deviceSerial() const = 0;
    virtual QString deviceModel() const = 0;
    virtual QString deviceManufacturer() const = 0;

    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbackType) = 0;

    Q_INVOKABLE QVariantMap getSafeAreaMargins(QQuickWindow *window);
signals:
    void permissionsRequestFinished();
};

#endif // PLATFORMHELPER_H
