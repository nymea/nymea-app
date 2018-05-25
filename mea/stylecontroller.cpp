#include <QSettings>
#include <QQuickStyle>
#include <QDir>

#include "stylecontroller.h"

StyleController::StyleController(QObject *parent) : QObject(parent)
{
#ifdef BRANDING
    QQuickStyle::setStyle(QString(":/styles/%1").arg(BRANDING));
#else
    QQuickStyle::setStyle(QString(":/styles/%1").arg(currentStyle()));
#endif
}

QString StyleController::currentStyle() const
{
#ifdef BRANDING
    return BRANDING;
#endif
    QSettings settings;
    return settings.value("style", "light").toString();
}

void StyleController::setCurrentStyle(const QString &currentStyle)
{
    QSettings settings;
    if (settings.value("style").toString() != currentStyle) {
        settings.setValue("style", currentStyle);
        emit currentStyleChanged();
    }
}

QStringList StyleController::allStyles() const
{
    QDir dir(":/styles/");
    return dir.entryList(QDir::Dirs);
}
