#include "mouseobserver.h"

#include <QCursor>
#include <QQuickWindow>

MouseObserver::MouseObserver(QQuickItem *parent) : QQuickItem(parent)
{
    qCritical() << "*************************** creating observer" << window();

    EventFilter *filter = new EventFilter(this);
    connect(filter, &EventFilter::pressed, this, [=](){
        m_timer.start();
    });
    connect(filter, &EventFilter::released, this, [=](){
        m_timer.stop();
    });
    installEventFilter(filter);
    setAcceptedMouseButtons(Qt::AllButtons);


    m_timer.setInterval(200);
    m_timer.setSingleShot(true);
    connect(&m_timer, &QTimer::timeout, this, &MouseObserver::longPressed);
}



EventFilter::EventFilter(QObject *parent): QObject(parent)
{

}

bool EventFilter::eventFilter(QObject *watched, QEvent *event)
{
    qWarning() << "************ eventfilter" << event->type();
    return QObject::eventFilter(watched, event);
}
