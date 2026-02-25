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

#ifndef STYLECONTROLLER_H
#define STYLECONTROLLER_H

#include <QObject>

class StyleController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentStyle READ currentStyle WRITE setCurrentStyle NOTIFY currentStyleChanged)
    Q_PROPERTY(QStringList allStyles READ allStyles CONSTANT)
    Q_PROPERTY(bool locked READ locked CONSTANT)

public:
    explicit StyleController(const QString &defaultStyle, QObject *parent = nullptr);

    QString currentStyle() const;
    void setCurrentStyle(const QString &currentStyle);
    void lockToStyle(const QString &style);

    QStringList allStyles() const;
    bool locked() const;

    Q_INVOKABLE void setSystemFont(const QFont &font);

signals:
    void currentStyleChanged();

private:
    QString m_defaultStyle;
    bool m_locked = false;
};

#endif // STYLECONTROLLER_H
