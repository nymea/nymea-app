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
    Q_PROPERTY(QString hideTagId READ hideTagId WRITE setHideTagId NOTIFY hideTagIdChanged)
    Q_PROPERTY(QString hideTagValue READ hideTagValue WRITE setHideTagValue NOTIFY hideTagValueChanged)
    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(QStringList hiddenInterfaces READ hiddenInterfaces WRITE setHiddenInterfaces NOTIFY hiddenInterfacesChanged)
    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged)

    Q_PROPERTY(QStringList shownThingClassIds READ shownThingClassIds WRITE setShownThingClassIds NOTIFY shownThingClassIdsChanged)
    Q_PROPERTY(QStringList hiddenThingClassIds READ hiddenThingClassIds WRITE setHiddenThingClassIds NOTIFY hiddenThingClassIdsChanged)
    Q_PROPERTY(QStringList shownThingIds READ shownThingIds WRITE setShownThingIds NOTIFY shownThingIdsChanged)
    Q_PROPERTY(QStringList hiddenThingIds READ hiddenThingIds WRITE setHiddenThingIds NOTIFY hiddenThingIdsChanged)

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

    // A map of paramName:value pairs, all given need to match
    Q_PROPERTY(QVariantMap paramsFilter READ paramsFilter WRITE setParamsFilter NOTIFY paramsFilterChanged)

    // A map of stateName:value pairs, all given need to match
    Q_PROPERTY(QVariantMap stateFilter READ stateFilter WRITE setStateFilter NOTIFY stateFilterChanged)

    Q_PROPERTY(bool groupByInterface READ groupByInterface WRITE setGroupByInterface NOTIFY groupByInterfaceChanged)

    // If set, sorting will happen for the value of the given state. Make sure the filter is set to contain only things that have the given state
    // Does not work in combination with groupByInterface
    Q_PROPERTY(QString sortStateName READ sortStateName WRITE setSortStateName NOTIFY sortStateNameChanged)

    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

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

    QString hideTagId() const;
    void setHideTagId(const QString &tagId);

    QString hideTagValue() const;
    void setHideTagValue(const QString &tagValue);

    QString filterThingId() const;
    void setFilterThingId(const QString &filterThingId);

    QStringList shownInterfaces() const;
    void setShownInterfaces(const QStringList &shownInterfaces);

    QStringList hiddenInterfaces() const;
    void setHiddenInterfaces(const QStringList &hiddenInterfaces);

    QString nameFilter() const;
    void setNameFilter(const QString &nameFilter);

    QStringList shownThingClassIds() const;
    void setShownThingClassIds(const QStringList &shownThingClassIds);

    QStringList hiddenThingClassIds() const;
    void setHiddenThingClassIds(const QStringList &hiddenThingClassIds);

    QStringList shownThingIds() const;
    void setShownThingIds(const QStringList &shownThingIds);

    QStringList hiddenThingIds() const;
    void setHiddenThingIds(const QStringList &hiddenThingIds);

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

    QVariantMap paramsFilter() const;
    void setParamsFilter(const QVariantMap &paramsFilter);

    QVariantMap stateFilter() const;
    void setStateFilter(const QVariantMap &stateFilter);

    bool groupByInterface() const;
    void setGroupByInterface(bool groupByInterface);

    QString sortStateName() const;
    void setSortStateName(const QString &sortStateName);

    void setSortOrder(Qt::SortOrder sortOrder);

    Q_INVOKABLE Thing *get(int index) const;
    Q_INVOKABLE Thing *getThing(const QUuid &thingId) const;
    Q_INVOKABLE int indexOf(Thing *thing) const;

signals:
    void engineChanged();
    void parentProxyChanged();
    void filterTagIdChanged();
    void filterTagValueChanged();
    void hideTagIdChanged();
    void hideTagValueChanged();
    void filterThingIdChanged();
    void shownInterfacesChanged();
    void hiddenInterfacesChanged();
    void nameFilterChanged();
    void shownThingClassIdsChanged();
    void hiddenThingClassIdsChanged();
    void shownThingIdsChanged();
    void hiddenThingIdsChanged();
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
    void paramsFilterChanged();
    void stateFilterChanged();
    void groupByInterfaceChanged();
    void sortStateNameChanged();
    void sortOrderChanged();
    void countChanged();

private slots:
    void invalidateFilterInternal();

private:
    Thing *getInternal(int source_index) const;

    Engine *m_engine = nullptr;
    ThingsProxy *m_parentProxy = nullptr;
    QString m_filterTagId;
    QString m_filterTagValue;
    QString m_hideTagId;
    QString m_hideTagValue;
    QString m_filterThingId;
    QStringList m_shownInterfaces;
    QStringList m_hiddenInterfaces;
    QString m_nameFilter;
    QList<QUuid> m_shownThingClassIds;
    QList<QUuid> m_hiddenThingClassIds;
    QList<QUuid> m_shownThingIds;
    QList<QUuid> m_hiddenThingIds;

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

    QVariantMap m_paramsFilter;
    QVariantMap m_stateFilter;

    bool m_groupByInterface = false;

    QString m_sortStateName;

    int m_oldCount = 0;

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
};

#endif // THINGSPROXY_H
