#include <QSettings>
#include <QQuickStyle>
#include <QDir>
#include <QDebug>

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
    QString currentSetting = settings.value("style", "light").toString();
    // ensure style is available
    if (allStyles().contains(currentSetting)) {
        return currentSetting;
    }
    return allStyles().first();
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
//    qDebug() << "styles:" << dir.entryList();
    return dir.entryList(QDir::Dirs);
}

QString StyleController::currentExperience() const
{
    QSettings settings;
    return settings.value("experience", "Default").toString();
}

void StyleController::setCurrentExperience(const QString &currentExperience)
{
    QSettings settings;
    if (settings.value("experience").toString() != currentExperience) {
        settings.setValue("experience", currentExperience);
        emit currentExperienceChanged();
    }
}

QStringList StyleController::allExperiences() const
{
    QDir dir(":/ui/experiences");
    qDebug() << "experiences:" << dir.entryList();
    return QStringList() << "Default" << dir.entryList();
}
