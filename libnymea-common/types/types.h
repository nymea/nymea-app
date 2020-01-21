/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
