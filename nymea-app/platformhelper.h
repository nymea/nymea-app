#ifndef PLATFORMHELPER_H
#define PLATFORMHELPER_H

#include <QObject>
#include <QColor>

class PlatformHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasPermissions READ hasPermissions NOTIFY permissionsRequestFinished)
    Q_PROPERTY(QString deviceSerial READ deviceSerial CONSTANT)
    Q_PROPERTY(QString device READ device CONSTANT)
    Q_PROPERTY(QString deviceModel READ deviceModel CONSTANT)
    Q_PROPERTY(QString deviceManufacturer READ deviceManufacturer CONSTANT)
    Q_PROPERTY(QString machineHostname READ machineHostname CONSTANT)
    Q_PROPERTY(bool canControlScreen READ canControlScreen CONSTANT)
    Q_PROPERTY(int screenTimeout READ screenTimeout WRITE setScreenTimeout NOTIFY screenTimeoutChanged)
    Q_PROPERTY(int screenBrightness READ screenBrightness WRITE setScreenBrightness NOTIFY screenBrightnessChanged)
    Q_PROPERTY(QColor topPanelColor READ topPanelColor WRITE setTopPanelColor NOTIFY topPanelColorChanged)
    Q_PROPERTY(QColor bottomPanelColor READ bottomPanelColor WRITE setBottomPanelColor NOTIFY bottomPanelColorChanged)

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
    virtual QString device() const = 0;
    virtual QString deviceSerial() const = 0;
    virtual QString deviceModel() const = 0;
    virtual QString deviceManufacturer() const = 0;

    virtual bool canControlScreen() const;
    virtual int screenTimeout() const;
    virtual void setScreenTimeout(int screenTimeout);
    virtual int screenBrightness() const;
    virtual void setScreenBrightness(int percent);

    virtual QColor topPanelColor() const;
    virtual void setTopPanelColor(const QColor &color);
    virtual QColor bottomPanelColor() const;
    virtual void setBottomPanelColor(const QColor &color);


    Q_INVOKABLE virtual void vibrate(HapticsFeedback feedbackType) = 0;

signals:
    void permissionsRequestFinished();
    void screenTimeoutChanged();
    void screenBrightnessChanged();
    void topPanelColorChanged();
    void bottomPanelColorChanged();

private:
    QColor m_topPanelColor = QColor("black");
    QColor m_bottomPanelColor = QColor("black");
};

#endif // PLATFORMHELPER_H
