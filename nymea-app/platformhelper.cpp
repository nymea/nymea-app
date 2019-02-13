#include "platformhelper.h"

#include <QtGui/qpa/qplatformwindow.h>

PlatformHelper::PlatformHelper(QObject *parent) : QObject(parent)
{

}



QVariantMap PlatformHelper::getSafeAreaMargins(QQuickWindow *window)
{
//    QPlatformWindow *platformWindow = window->handle();
//    QMargins margins = platformWindow->safeAreaMargins();
    QVariantMap map;
//    map["top"] = margins.top();
//    map["right"] = margins.right();
//    map["bottom"] = margins.bottom();
//    map["left"] = margins.left();
    return map;
}
