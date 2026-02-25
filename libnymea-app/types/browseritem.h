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

#ifndef BROWSERITEM_H
#define BROWSERITEM_H

#include <QObject>
#include <QUuid>

class BrowserItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
    Q_PROPERTY(QString thumbnail READ thumbnail NOTIFY thumbnailChanged)
    Q_PROPERTY(bool executable READ executable NOTIFY executableChanged)
    Q_PROPERTY(bool browsable READ browsable NOTIFY browsableChanged)
    Q_PROPERTY(bool disabled READ disabled NOTIFY disabledChanged)
    Q_PROPERTY(QStringList actionTypeIds READ actionTypeIds NOTIFY actionTypeIdsChanged)

    Q_PROPERTY(QString mediaIcon READ mediaIcon NOTIFY mediaIconChanged)

public:
    explicit BrowserItem(const QString &id, QObject *parent = nullptr);

    QString id() const;

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    QString description() const;
    void setDescription(const QString &description);

    QString icon() const;
    void setIcon(const QString &icon);

    QString thumbnail() const;
    void setThumbnail(const QString &thumbnail);

    bool executable() const;
    void setExecutable(bool executable);

    bool browsable() const;
    void setBrowsable(bool browsable);

    bool disabled() const;
    void setDisabled(bool disabled);

    QStringList actionTypeIds() const;
    void setActionTypeIds(const QStringList &actionTypeIds);

    QString mediaIcon() const;
    void setMediaIcon(const QString &mediaIcon);

signals:
    void displayNameChanged();
    void descriptionChanged();
    void iconChanged();
    void thumbnailChanged();
    void executableChanged();
    void browsableChanged();
    void disabledChanged();
    void actionTypeIdsChanged();

    void mediaIconChanged();

private:
    QString m_id;
    QString m_displayName;
    QString m_description;
    QString m_icon;
    QString m_thumbnail;
    bool m_executable = false;
    bool m_browsable = false;
    bool m_disabled = false;
    QStringList m_actionTypeIds;

    QString m_mediaIcon;
};

#endif // BROWSERITEM_H
