// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef SCRIPTAUTOSAVER_H
#define SCRIPTAUTOSAVER_H

#include <QObject>
#include <QUuid>
#include <QFile>

class ScriptAutoSaver : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid scriptId READ scriptId WRITE setScriptId NOTIFY scriptIdChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(QString liveContent READ liveContent WRITE setLiveContent NOTIFY liveContentChanged)
    Q_PROPERTY(QString cachedContent READ cachedContent NOTIFY cachedContentChanged)

public:
    explicit ScriptAutoSaver(QObject *parent = nullptr);
    ~ScriptAutoSaver() override;

    bool available() const;

    bool active() const;
    void setActive(bool active);

    QUuid scriptId() const;
    void setScriptId(const QUuid &scriptId);

    QString liveContent() const;
    void setLiveContent(const QString &liveContent);

    QString cachedContent() const;

signals:
    void scriptIdChanged();
    void availableChanged();
    void activeChanged();
    void liveContentChanged();
    void cachedContentChanged();

private slots:
    void storeContent();

private:
    QUuid m_scriptId;
    QString m_cachedContent;
    QString m_liveContent;

    QFile m_cacheFile;

    bool m_active = false;
};

#endif // SCRIPTAUTOSAVER_H
