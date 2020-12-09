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

StyleController::StyleController(const QString &defaultStyle, QObject *parent) : QObject(parent),
    m_defaultStyle(defaultStyle)
{
    QQuickStyle::setStyle(QString(":/styles/%1").arg(currentStyle()));
}

QString StyleController::currentStyle() const
{
    QSettings settings;
    QString currentSetting = settings.value("style", m_defaultStyle).toString();
    // ensure style is available
    if (allStyles().contains(currentSetting)) {
        return currentSetting;
    }
    return allStyles().first();
}

void StyleController::setCurrentStyle(const QString &currentStyle)
{
    if (m_locked) {
        qDebug() << "Ignoring style change request. Style is locked to" << this->currentStyle();
        return;
    }
    if (!allStyles().contains(currentStyle)) {
        qWarning().nospace() << "No style named: " << currentStyle << ". Available styles are: " << allStyles().join(", ");
        return;
    }
    QSettings settings;
    if (settings.value("style").toString() != currentStyle) {
        settings.setValue("style", currentStyle);
        QQuickStyle::setStyle(QString(":/styles/%1").arg(currentStyle));
        emit currentStyleChanged();
    }
}

void StyleController::lockToStyle(const QString &style)
{
    setCurrentStyle(style);
    m_locked = true;
}

QStringList StyleController::allStyles() const
{
    QDir dir(":/styles/");
//    qDebug() << "styles:" << dir.entryList();
    return dir.entryList(QDir::Dirs);
}

bool StyleController::locked() const
{
    return m_locked;
}

void StyleController::setSystemFont(const QFont &font)
{
    QApplication::setFont(font);
}
