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

#ifndef STATETYPESPROXY_H
#define STATETYPESPROXY_H

#include <QSortFilterProxyModel>

#include "statetypes.h"

class StateTypesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_PROPERTY(StateTypes* stateTypes READ stateTypes WRITE setStateTypes NOTIFY stateTypesChanged)
    Q_PROPERTY(bool digitalInputs READ digitalInputs WRITE setDigitalInputs NOTIFY digitalInputsChanged)
    Q_PROPERTY(bool digitalOutputs READ digitalOutputs WRITE setDigitalOutputs NOTIFY digitalOutputsChanged)
    Q_PROPERTY(bool analogInputs READ analogInputs WRITE setAnalogInputs NOTIFY analogInputsChanged)
    Q_PROPERTY(bool analogOutputs READ analogOutputs WRITE setAnalogOutputs NOTIFY analogOutputsChanged)

public:
    explicit StateTypesProxy(QObject *parent = nullptr);

    StateTypes* stateTypes() const;
    void setStateTypes(StateTypes *stateTypes);

    bool digitalInputs() const;
    void setDigitalInputs(bool digitalInputs);

    bool digitalOutputs() const;
    void setDigitalOutputs(bool digitalOutputs);

    bool analogInputs() const;
    void setAnalogInputs(bool analogInputs);

    bool analogOutputs() const;
    void setAnalogOutputs(bool analogOutputs);

    Q_INVOKABLE StateType* get(int index) const;

signals:
    void countChanged();
    void stateTypesChanged();
    void digitalInputsChanged();
    void digitalOutputsChanged();
    void analogInputsChanged();
    void analogOutputsChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    StateTypes *m_stateTypes = nullptr;

    bool m_digitalInputs = false;
    bool m_digitalOutputs = false;
    bool m_analogInputs = false;
    bool m_analogOutputs = false;
};

#endif // STATETYPESPROXY_H
