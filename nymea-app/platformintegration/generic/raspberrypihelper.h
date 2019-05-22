#ifndef RASPBERRYPIHELPER_H
#define RASPBERRYPIHELPER_H

#include <QObject>
#include <QTimer>
#include <QFile>

class RaspberryPiHelper : public QObject
{
    Q_OBJECT
public:
    explicit RaspberryPiHelper(QObject *parent = nullptr);

    bool active() const;
    int screenTimeout() const;
    void setScreenTimeout(int timeout);

    bool eventFilter(QObject *watched, QEvent *event) override;

private slots:
    void screenOn();
    void screenOff();

private:
    QTimer m_screenOffTimer;
    QFile m_sysFsFile;
};

#endif // RASPBERRYPIHELPER_H
