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
