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

#ifndef THINGSPROXY_H
#define THINGSPROXY_H

#include <QUuid>
#include <QObject>
#include <QSortFilterProxyModel>

#include "things.h"

class Engine;

class ThingsProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(ThingsProxy *parentProxy READ parentProxy WRITE setParentProxy NOTIFY parentProxyChanged)
    Q_PROPERTY(QString filterTagId READ filterTagId WRITE setFilterTagId NOTIFY filterTagIdChanged)
    Q_PROPERTY(QString filterTagValue READ filterTagValue WRITE setFilterTagValue NOTIFY filterTagValueChanged)
    Q_PROPERTY(QString filterThingId READ filterThingId WRITE setFilterThingId NOTIFY filterThingIdChanged)
    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(QStringList hiddenInterfaces READ hiddenInterfaces WRITE setHiddenInterfaces NOTIFY hiddenInterfacesChanged)
    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged)

    Q_PROPERTY(QList<QUuid> shownThingClassIds READ shownThingClassIds WRITE setShownThingClassIds NOTIFY shownThingClassIdsChanged)
    Q_PROPERTY(QList<QUuid> hiddenThingClassIds READ hiddenThingClassIds WRITE setHiddenThingClassIds NOTIFY hiddenThingClassIdsChanged)

    Q_PROPERTY(QString requiredEventName READ requiredEventName WRITE setRequiredEventName NOTIFY requiredEventNameChanged)
    Q_PROPERTY(QString requiredStateName READ requiredStateName WRITE setRequiredStateName NOTIFY requiredStateNameChanged)
    Q_PROPERTY(QString requiredActionName READ requiredActionName WRITE setRequiredActionName NOTIFY requiredActionNameChanged)

    // Setting one of those to true will hide those set to false. If all of those are false no IO filtering will be done
    Q_PROPERTY(bool showDigitalInputs READ showDigitalInputs WRITE setShowDigitalInputs NOTIFY showDigitalInputsChanged)
    Q_PROPERTY(bool showDigitalOutputs READ showDigitalOutputs WRITE setShowDigitalOutputs NOTIFY showDigitalOutputsChanged)
    Q_PROPERTY(bool showAnalogInputs READ showAnalogInputs WRITE setShowAnalogInputs NOTIFY showAnalogInputsChanged)
    Q_PROPERTY(bool showAnalogOutputs READ showAnalogOutputs WRITE setShowAnalogOutputs NOTIFY showAnalogOutputsChanged)

    // Setting this to true will imply filtering for "battery" interface
    Q_PROPERTY(bool filterBatteryCritical READ filterBatteryCritical WRITE setFilterBatteryCritical NOTIFY filterBatteryCriticalChanged)

    // Setting this to true will imply filtering for "connectable" interface
    Q_PROPERTY(bool filterDisconnected READ filterDisconnected WRITE setFilterDisconnected NOTIFY filterDisconnectedChanged)

    Q_PROPERTY(bool filterSetupFailed READ filterSetupFailed WRITE setFilterSetupFailed NOTIFY filterSetupFailedChanged)

    Q_PROPERTY(bool filterUpdates READ filterUpdates WRITE setFilterUpdates NOTIFY filterUpdatesChanged)

    Q_PROPERTY(bool groupByInterface READ groupByInterface WRITE setGroupByInterface NOTIFY groupByInterfaceChanged)

public:
    explicit ThingsProxy(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    ThingsProxy *parentProxy() const;
    void setParentProxy(ThingsProxy *parentProxy);

    QString filterTagId() const;
    void setFilterTagId(const QString &filterTag);

    QString filterTagValue() const;
    void setFilterTagValue(const QString &tagValue);

    QString filterThingId() const;
    void setFilterThingId(const QString &filterThingId);

    QStringList shownInterfaces() const;
    void setShownInterfaces(const QStringList &shownInterfaces);

    QStringList hiddenInterfaces() const;
    void setHiddenInterfaces(const QStringList &hiddenInterfaces);

    QString nameFilter() const;
    void setNameFilter(const QString &nameFilter);

    QList<QUuid> shownThingClassIds() const;
    void setShownThingClassIds(const QList<QUuid> &shownThingClassIds);

    QList<QUuid> hiddenThingClassIds() const;
    void setHiddenThingClassIds(const QList<QUuid> &hiddenThingClassIds);

    QString requiredEventName() const;
    void setRequiredEventName(const QString &requiredEventName);

    QString requiredStateName() const;
    void setRequiredStateName(const QString &requiredStateName);

    QString requiredActionName() const;
    void setRequiredActionName(const QString &requiredActionName);

    bool showDigitalInputs() const;
    void setShowDigitalInputs(bool showDigitalInputs);

    bool showDigitalOutputs() const;
    void setShowDigitalOutputs(bool showDigitalOutputs);

    bool showAnalogInputs() const;
    void setShowAnalogInputs(bool showAnalogInputs);

    bool showAnalogOutputs() const;
    void setShowAnalogOutputs(bool showAnalogOutputs);

    bool filterBatteryCritical() const;
    void setFilterBatteryCritical(bool filterBatteryCritical);

    bool filterDisconnected() const;
    void setFilterDisconnected(bool filterDisconnected);

    bool filterSetupFailed() const;
    void setFilterSetupFailed(bool filterSetupFailed);

    bool filterUpdates() const;
    void setFilterUpdates(bool filterUpdates);

    bool groupByInterface() const;
    void setGroupByInterface(bool groupByInterface);

    Q_INVOKABLE Thing *get(int index) const;
    Q_INVOKABLE Thing *getThing(const QUuid &thingId) const;
    Q_INVOKABLE int indexOf(Thing *thing) const;

signals:
    void engineChanged();
    void parentProxyChanged();
    void filterTagIdChanged();
    void filterTagValueChanged();
    void filterThingIdChanged();
    void shownInterfacesChanged();
    void hiddenInterfacesChanged();
    void nameFilterChanged();
    void shownThingClassIdsChanged();
    void hiddenThingClassIdsChanged();
    void requiredEventNameChanged();
    void requiredStateNameChanged();
    void requiredActionNameChanged();
    void showDigitalInputsChanged();
    void showDigitalOutputsChanged();
    void showAnalogInputsChanged();
    void showAnalogOutputsChanged();
    void filterBatteryCriticalChanged();
    void filterDisconnectedChanged();
    void filterSetupFailedChanged();
    void filterUpdatesChanged();
    void groupByInterfaceChanged();
    void countChanged();

private:
    Thing *getInternal(int source_index) const;

    Engine *m_engine = nullptr;
    ThingsProxy *m_parentProxy = nullptr;
    QString m_filterTagId;
    QString m_filterTagValue;
    QString m_filterThingId;
    QStringList m_shownInterfaces;
    QStringList m_hiddenInterfaces;
    QString m_nameFilter;
    QList<QUuid> m_shownThingClassIds;
    QList<QUuid> m_hiddenThingClassIds;

    QString m_requiredEventName;
    QString m_requiredStateName;
    QString m_requiredActionName;

    bool m_showDigitalInputs = false;
    bool m_showDigitalOutputs = false;
    bool m_showAnalogInputs = false;
    bool m_showAnalogOutputs = false;

    bool m_filterBatteryCritical = false;
    bool m_filterDisconnected = false;
    bool m_filterSetupFailed = false;
    bool m_filterUpdates = false;

    bool m_groupByInterface = false;

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
};

#endif // THINGSPROXY_H
