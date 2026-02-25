// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
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
