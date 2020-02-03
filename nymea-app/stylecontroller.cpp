/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <QSettings>
#include <QQuickStyle>
#include <QDir>
#include <QDebug>
#include <QApplication>

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

void StyleController::setSystemFont(const QFont &font)
{
    QApplication::setFont(font);
}
