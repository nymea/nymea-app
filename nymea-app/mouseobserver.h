#ifndef MOUSEOBSERVER_H
#define MOUSEOBSERVER_H

#include <QQuickItem>
#include <QTimer>

class MouseObserver : public QQuickItem
{
    Q_OBJECT
public:
    explicit MouseObserver(QQuickItem *parent = nullptr);

signals:
    void longPressed();


private:
    QTimer m_timer;
};

class EventFilter: public QObject
{
    Q_OBJECT
public:
    explicit EventFilter(QObject *parent = nullptr);

    bool eventFilter(QObject *watched, QEvent *event) override;

signals:
    void pressed();
    void released();

};


#endif // MOUSEOBSERVER_H
