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

#ifndef THINGMANAGER_H
#define THINGMANAGER_H

#include <QObject>

#include "types/vendors.h"
#include "things.h"
#include "thingclasses.h"
#include "interfacesmodel.h"
#include "types/plugins.h"
#include "jsonrpc/jsonrpcclient.h"

class BrowserItem;
class BrowserItems;
class ThingGroup;
class Interface;
class IOConnections;
class EventHandler;

class ThingManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Vendors* vendors READ vendors CONSTANT)
    Q_PROPERTY(Plugins* plugins READ plugins CONSTANT)
    Q_PROPERTY(Things* things READ things CONSTANT)
    Q_PROPERTY(ThingClasses* thingClasses READ thingClasses CONSTANT)
    Q_PROPERTY(IOConnections* ioConnections READ ioConnections CONSTANT)

    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

    Q_ENUMS(RemovePolicy)
public:
    enum RemovePolicy {
        RemovePolicyNone,
        RemovePolicyCascade,
        RemovePolicyUpdate
    };
    Q_ENUM(RemovePolicy)

    explicit ThingManager(JsonRpcClient *jsonclient, QObject *parent = nullptr);

    void clear();
    void init();

    Vendors* vendors() const;
    Plugins* plugins() const;
    Things* things() const;
    ThingClasses* thingClasses() const;
    IOConnections* ioConnections() const;

    bool fetchingData() const;

    Q_INVOKABLE int addThing(const QUuid &thingClassId, const QString &name, const QVariantList &thingParams);
    // Param thingClassId is deprecated as of jsonrpc 5.4
    Q_INVOKABLE int addDiscoveredThing(const QUuid &thingClassId, const QUuid &thingDescriptorId, const QString &name, const QVariantList &thingParams);
    Q_INVOKABLE int pairThing(const QUuid &thingClassId, const QVariantList &thingParams, const QString &name);
    Q_INVOKABLE int pairDiscoveredThing(const QUuid &thingDescriptorId, const QVariantList &thingParams, const QString &name);
    Q_INVOKABLE int rePairThing(const QUuid &thingId, const QVariantList &thingParams, const QString &name = QString());
    Q_INVOKABLE int confirmPairing(const QUuid &pairingTransactionId, const QString &secret = QString(), const QString &username = QString());
    Q_INVOKABLE int removeThing(const QUuid &thingId, RemovePolicy policy = RemovePolicyNone);
    Q_INVOKABLE int editThing(const QUuid &thingId, const QString &name);
    Q_INVOKABLE int setThingSettings(const QUuid &thingId, const QVariantList &settings);
    Q_INVOKABLE int reconfigureThing(const QUuid &thingId, const QVariantList &thingParams);
    Q_INVOKABLE int reconfigureDiscoveredThing(const QUuid &thingDescriptorId, const QVariantList &paramOverride);
    Q_INVOKABLE int executeAction(const QUuid &thingId, const QUuid &actionTypeId, const QVariantList &params = QVariantList());
    Q_INVOKABLE BrowserItems* browseThing(const QUuid &thingId, const QString &itemId = QString());
    Q_INVOKABLE void refreshBrowserItems(BrowserItems *browserItems);
    Q_INVOKABLE BrowserItem* browserItem(const QUuid &thingId, const QString &itemId);
    Q_INVOKABLE int executeBrowserItem(const QUuid &thingId, const QString &itemId);
    Q_INVOKABLE int executeBrowserItemAction(const QUuid &thingId, const QString &itemId, const QUuid &actionTypeId, const QVariantList &params = QVariantList());

    Q_INVOKABLE int connectIO(const QUuid &inputThingId, const QUuid &inputStateTypeId, const QUuid &outputThingId, const QUuid &outputStateTypeId, bool inverted);
    Q_INVOKABLE int disconnectIO(const QUuid &ioConnectionId);

private:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);
    Q_INVOKABLE void getVendorsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getThingClassesResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getPluginsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getThingsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void addThingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void removeThingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void pairThingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void confirmPairingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void setPluginConfigResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void editThingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void executeActionResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void reconfigureThingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void browseThingResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void browserItemResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void executeBrowserItemResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void executeBrowserItemActionResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void getIOConnectionsResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void connectIOResponse(int commandId, const QVariantMap &params);
    Q_INVOKABLE void disconnectIOResponse(int commandId, const QVariantMap &params);

public slots:
    ThingGroup* createGroup(Interface *interface, ThingsProxy *things);

signals:
    void addThingReply(int commandId, Thing::ThingError thingError, const QUuid &thingId, const QString &displayMessage);
    void pairThingReply(int commandId, Thing::ThingError thingError, const QUuid &pairingTransactionId, const QString &setupMethod, const QString &displayMessage, const QString &oAuthUrl);
    void confirmPairingReply(int commandId, Thing::ThingError thingError, const QUuid &thingId, const QString &displayMessage);
    void removeThingReply(int commandId, Thing::ThingError thingError, const QStringList ruleIds);
    void savePluginConfigReply(int commandId, Thing::ThingError thingError);
    void editThingReply(int commandId, Thing::ThingError thingError);
    void reconfigureThingReply(int commandId, Thing::ThingError thingError, const QString &displayMessage);
    void executeActionReply(int commandId, Thing::ThingError thingError, const QString &displayMessage);
    void executeBrowserItemReply(int commandId, Thing::ThingError thingError, const QString &displayMessage);
    void executeBrowserItemActionReply(int commandId, Thing::ThingError thingError, const QString &displayMessage);
    void fetchingDataChanged();
    void notificationReceived(const QString &thingId, const QString &eventTypeId, const QVariantList &params);

    void eventTriggered(const QUuid &thingId, const QUuid &eventTypeId, const QVariantMap params);
    void thingStateChanged(const QUuid &thingId, const QUuid &stateTypeId, const QVariant &value);

    void thingAdded(Thing *thing);
    void thingRemoved(Thing *thing);

private:
    static Vendor *unpackVendor(const QVariantMap &vendorMap);
    static Plugin *unpackPlugin(const QVariantMap &pluginMap, QObject *parent);
    static ThingClass *unpackThingClass(const QVariantMap &thingClassMap);
    static void unpackParam(const QVariantMap &paramMap, Param *param);
    static ParamType *unpackParamType(const QVariantMap &paramTypeMap, QObject *parent);
    static StateType *unpackStateType(const QVariantMap &stateTypeMap, QObject *parent);
    static EventType *unpackEventType(const QVariantMap &eventTypeMap, QObject *parent);
    static ActionType *unpackActionType(const QVariantMap &actionTypeMap, QObject *parent);
    static Thing *unpackThing(ThingManager *thingManager, const QVariantMap &thingMap, ThingClasses *thingClasses, Thing *oldThing = nullptr);

    static QVariantMap packParam(Param *param);

    static Thing::ThingError errorFromString(const QByteArray &thingErrorString);
    static ThingClass::SetupMethod stringToSetupMethod(const QString &setupMethodString);
    static Types::Unit stringToUnit(const QString &unitString);
    static Types::InputType stringToInputType(const QString &inputTypeString);

private:
    Vendors *m_vendors;
    Plugins *m_plugins;
    Things *m_things;
    ThingClasses *m_thingClasses;
    IOConnections *m_ioConnections;

    bool m_fetchingData = true;

    JsonRpcClient *m_jsonClient = nullptr;

    QHash<int, QPointer<BrowserItems> > m_browsingRequests;
    QHash<int, QPointer<BrowserItem> > m_browserDetailsRequests;

    QDateTime m_connectionBenchmark;
};

Q_DECLARE_METATYPE(QList<QUuid>)

#endif // THINGMANAGER_H
