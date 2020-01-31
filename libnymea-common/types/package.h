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

#ifndef PACKAGE_H
#define PACKAGE_H

#include <QObject>

class Package : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(QString summary READ summary NOTIFY summaryChanged)
    Q_PROPERTY(QString installedVersion READ installedVersion NOTIFY installedVersionChanged)
    Q_PROPERTY(QString candidateVersion READ candidateVersion NOTIFY candidateVersionChanged)
    Q_PROPERTY(QString changelog READ changelog NOTIFY changelogChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(bool rollbackAvailable READ rollbackAvailable NOTIFY rollbackAvailableChanged)
    Q_PROPERTY(bool canRemove READ canRemove NOTIFY canRemoveChanged)

public:
    explicit Package(const QString &id, const QString &displayName, QObject *parent = nullptr);

    QString id() const;
    QString displayName() const;

    QString summary() const;
    void setSummary(const QString &summary);

    QString installedVersion() const;
    void setInstalledVersion(const QString &installedVersion);

    QString candidateVersion() const;
    void setCandidateVersion(const QString &candidateVersion);

    QString changelog() const;
    void setChangelog(const QString &changelog);

    bool updateAvailable() const;
    void setUpdateAvailable(bool updateAvailable);

    bool rollbackAvailable() const;
    void setRollbackAvailable(bool rollbackAvailable);

    bool canRemove() const;
    void setCanRemove(bool canRemove);

signals:
    void summaryChanged();
    void installedVersionChanged();
    void candidateVersionChanged();
    void changelogChanged();
    void updateAvailableChanged();
    void rollbackAvailableChanged();
    void canRemoveChanged();

private:
    QString m_id;
    QString m_displayName;
    QString m_summary;
    QString m_installedVersion;
    QString m_candidateVersion;
    QString m_changelog;
    bool m_updateAvailable = false;
    bool m_rollbackAvailable = false;
    bool m_canRemove = false;
};

#endif // PACKAGE_H
