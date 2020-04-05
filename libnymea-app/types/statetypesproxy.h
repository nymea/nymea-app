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
