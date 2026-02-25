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

#include "package.h"

Package::Package(const QString &id, const QString &displayName, QObject *parent):
    QObject(parent),
    m_id(id),
    m_displayName(displayName)
{

}

QString Package::id() const
{
    return m_id;
}

QString Package::displayName() const
{
    return m_displayName;
}

QString Package::summary() const
{
    return m_summary;
}

void Package::setSummary(const QString &summary)
{
    if(m_summary != summary) {
        m_summary = summary;
        emit summaryChanged();
    }
}

QString Package::installedVersion() const
{
    return m_installedVersion;
}

void Package::setInstalledVersion(const QString &installedVersion)
{
    if (m_installedVersion != installedVersion) {
        m_installedVersion = installedVersion;
        emit installedVersionChanged();
    }
}

QString Package::candidateVersion() const
{
    return m_candidateVersion;
}

void Package::setCandidateVersion(const QString &candidateVersion)
{
    if (m_candidateVersion != candidateVersion) {
        m_candidateVersion = candidateVersion;
        emit candidateVersionChanged();
    }
}

QString Package::changelog() const
{
    return m_changelog;
}

void Package::setChangelog(const QString &changelog)
{
    if (m_changelog != changelog) {
        m_changelog = changelog;
        emit changelogChanged();
    }
}

bool Package::updateAvailable() const
{
    return m_updateAvailable;
}

void Package::setUpdateAvailable(bool updateAvailable)
{
    if (m_updateAvailable != updateAvailable) {
        m_updateAvailable = updateAvailable;
        emit updateAvailableChanged();
    }
}

bool Package::rollbackAvailable() const
{
    return m_rollbackAvailable;
}

void Package::setRollbackAvailable(bool rollbackAvailable)
{
    if (m_rollbackAvailable != rollbackAvailable) {
        m_rollbackAvailable = rollbackAvailable;
        emit rollbackAvailableChanged();
    }
}

bool Package::canRemove() const
{
    return m_canRemove;
}

void Package::setCanRemove(bool canRemove)
{
    if (m_canRemove != canRemove) {
        m_canRemove = canRemove;
        emit canRemoveChanged();
    }
}
