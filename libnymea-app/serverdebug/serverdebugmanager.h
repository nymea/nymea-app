/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2024, nymea GmbH
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

#ifndef SERVERDEBUGMANAGER_H
#define SERVERDEBUGMANAGER_H

#include <QObject>

#include "engine.h"
#include "serverloggingcategories.h"

class JsonRpcClient;

class ServerDebugManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged FINAL)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged FINAL)
    Q_PROPERTY(ServerLoggingCategories *categories READ categories CONSTANT FINAL)

public:
    explicit ServerDebugManager(QObject *parent = nullptr);
    ~ServerDebugManager();

    Engine *engine() const;
    void setEngine(Engine *engine);

    ServerLoggingCategories *categories() const;

    bool fetchingData() const;

    Q_INVOKABLE void getLoggingCategories();
    Q_INVOKABLE void setLoggingLevel(const QString &name, int level);

signals:
    void engineChanged();
    void fetchingDataChanged();

private slots:
    void notificationReceived(const QVariantMap &notification);

private:
    Engine *m_engine = nullptr;
    ServerLoggingCategories *m_categories = nullptr;

    bool m_fetchingData = false;

    void init();

    Q_INVOKABLE void getLoggingCategoriesResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setLoggingCategoryLevelResponse(int commandId, const QVariantMap &params);

};

#endif // SERVERDEBUGMANAGER_H
