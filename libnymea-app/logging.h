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

#ifndef LOGGING_H
#define LOGGING_H

#include <QLoggingCategory>

QStringList& nymeaLoggingCategories();

#define NYMEA_LOGGING_CATEGORY(name, string) \
    class NymeaLoggingCategory##name: public QLoggingCategory { \
    public: \
    NymeaLoggingCategory##name(): QLoggingCategory(string) { nymeaLoggingCategories().append(string); } \
    }; \
    static NymeaLoggingCategory##name s_##name; \
    const QLoggingCategory &name() \
    { \
        return s_##name; \
    } \


#endif // LOGGING_H
