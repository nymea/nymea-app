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

#ifndef SCRIPTSPROXYMODEL_H
#define SCRIPTSPROXYMODEL_H

#include <QSortFilterProxyModel>

#include "types/scripts.h"

class ScriptsProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Scripts* scripts READ scripts WRITE setScripts NOTIFY scriptsChanged)

    Q_PROPERTY(QString filterName READ filterName WRITE setFilterName NOTIFY filterNameChanged)

public:
    explicit ScriptsProxyModel(QObject *parent = nullptr);

    Scripts* scripts() const;
    void setScripts(Scripts *scripts);

    QString filterName() const;
    void setFilterName(const QString &filterName);

    Script* get(int index) const;

signals:
    void countChanged();
    void scriptsChanged();
    void filterNameChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    Scripts* m_scripts = nullptr;

    QString m_filterName;
};

#endif // SCRIPTSPROXYMODEL_H
