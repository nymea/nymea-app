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

#ifndef TYPES_H
#define TYPES_H

#include <QObject>
#include <QVariant>

class Types: public QObject
{
    Q_OBJECT
    Q_PROPERTY(UnitSystem unitSystem READ unitSystem WRITE setUnitSystem NOTIFY unitSystemChanged)

public:
    enum InputType {
        InputTypeNone,
        InputTypeTextLine,
        InputTypeTextArea,
        InputTypePassword,
        InputTypeSearch,
        InputTypeMail,
        InputTypeIPv4Address,
        InputTypeIPv6Address,
        InputTypeUrl,
        InputTypeMacAddress
    };
    Q_ENUM(InputType)

    enum Unit {
        UnitNone,
        UnitSeconds,
        UnitMinutes,
        UnitHours,
        UnitUnixTime,
        UnitMeterPerSecond,
        UnitKiloMeterPerHour,
        UnitDegree,
        UnitRadiant,
        UnitDegreeCelsius,
        UnitDegreeKelvin,
        UnitMired,
        UnitMilliBar,
        UnitBar,
        UnitPascal,
        UnitHectoPascal,
        UnitAtmosphere,
        UnitLumen,
        UnitLux,
        UnitCandela,
        UnitMilliMeter,
        UnitCentiMeter,
        UnitMeter,
        UnitKiloMeter,
        UnitGram,
        UnitKiloGram,
        UnitDezibel,
        UnitBpm,
        UnitKiloByte,
        UnitMegaByte,
        UnitGigaByte,
        UnitTeraByte,
        UnitMilliWatt,
        UnitWatt,
        UnitKiloWatt,
        UnitKiloWattHour,
        UnitEuroPerMegaWattHour,
        UnitEuroCentPerKiloWattHour,
        UnitPercentage,
        UnitPartsPerMillion,
        UnitEuro,
        UnitDollar,
        UnitHertz,
        UnitAmpere,
        UnitMilliAmpere,
        UnitVolt,
        UnitMilliVolt,
        UnitVoltAmpere,
        UnitVoltAmpereReactive,
        UnitAmpereHour,
        UnitMicroSiemensPerCentimeter,
        UnitDuration,

        // Those do not exist in nymea:core at this point, Adding them for easier conversion to imperial
        UnitDegreeFahrenheit,
        UnitOunce,
        UnitPound,
        UnitInch,
        UnitFoot,
        UnitMile,
        UnitFootPerSecond,
        UnitMilePerHour,
    };
    Q_ENUM(Unit)

    enum IOType {
        IOTypeNone,
        IOTypeDigitalInput,
        IOTypeDigitalOutput,
        IOTypeAnalogInput,
        IOTypeAnalogOutput
    };
    Q_ENUM(IOType)

    enum UnitSystem {
        UnitSystemMetric,
        UnitSystemImperial
    };
    Q_ENUM(UnitSystem)

    static Types* instance();

    UnitSystem unitSystem() const;
    void setUnitSystem(UnitSystem unitSystem);

    Q_INVOKABLE QString toUiUnit(Types::Unit unit) const;
    Q_INVOKABLE QVariant toUiValue(const QVariant &value, Types::Unit unit) const;

signals:
    void unitSystemChanged();

private:
    Types(QObject *parent = nullptr);
    static Types *s_instance;

    UnitSystem m_unitSystem = UnitSystemMetric;

};
#endif // TYPES_H
