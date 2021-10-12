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

#include "types.h"

#include <QDebug>

Types *Types::s_instance = nullptr;

Types::Types(QObject *parent) : QObject(parent)
{

}

Types *Types::instance()
{
    if (!s_instance) {
        s_instance = new Types();
    }
    return s_instance;
}

Types::UnitSystem Types::unitSystem() const
{
    return m_unitSystem;
}

void Types::setUnitSystem(Types::UnitSystem unitSystem)
{
    if (m_unitSystem != unitSystem) {
        m_unitSystem = unitSystem;
        emit unitSystemChanged();
    }
}

QString Types::toUiUnit(Types::Unit unit) const
{
    Types::Unit uiUnit = unit;
    if (m_unitSystem == UnitSystemImperial) {
        switch (unit) {
        case Types::UnitDegreeCelsius:
            uiUnit = Types::UnitDegreeFahrenheit;
            break;
        case Types::UnitGram:
            uiUnit = Types::UnitOunce;
            break;
        case Types::UnitKiloGram:
            uiUnit = Types::UnitPound;
            break;
        case Types::UnitMilliMeter:
        case Types::UnitCentiMeter:
            uiUnit = Types::UnitInch;
            break;
        case Types::UnitMeter:
            uiUnit = Types::UnitFoot;
            break;
        case Types::UnitKiloMeter:
            uiUnit = Types::UnitMile;
            break;
        case Types::UnitMeterPerSecond:
            uiUnit = Types::UnitFootPerSecond;
            break;
        case Types::UnitKiloMeterPerHour:
            uiUnit = Types::UnitMilePerHour;
            break;
        case Types::UnitMilliBar:
        case Types::UnitBar:
            uiUnit = Types::UnitPoundsPerSquareInch;
            break;
        case Types::UnitLiter:
            uiUnit = Types::UnitFluidOunce;
            break;
        default:
            uiUnit = unit;
        }
    }
    switch (uiUnit) {
    case Types::UnitNone:
        return "";
    case Types::UnitSeconds:
        return "s";
    case Types::UnitMinutes:
        return "m";
    case Types::UnitHours:
        return "h";
    case Types::UnitUnixTime:
        return "datetime";
    case Types::UnitMeterPerSecond:
        return "m/s";
    case Types::UnitKiloMeterPerHour:
        return "km/h";
    case Types::UnitDegree:
        return "°";
    case Types::UnitRadiant:
        return "rad";
    case Types::UnitDegreeCelsius:
        return "°C";
    case Types::UnitDegreeKelvin:
        return "°K";
    case Types::UnitMired:
        return "mir";
    case Types::UnitMilliBar:
        return "mbar";
    case Types::UnitBar:
        return "bar";
    case Types::UnitPascal:
        return "Pa";
    case Types::UnitHectoPascal:
        return "hPa";
    case Types::UnitAtmosphere:
        return "atm";
    case Types::UnitLumen:
        return "lm";
    case Types::UnitLux:
        return "lx";
    case Types::UnitCandela:
        return "cd";
    case Types::UnitMilliMeter:
        return "mm";
    case Types::UnitCentiMeter:
        return "cm";
    case Types::UnitMeter:
        return "m";
    case Types::UnitKiloMeter:
        return "km";
    case Types::UnitGram:
        return "g";
    case Types::UnitKiloGram:
        return "kg";
    case Types::UnitDezibel:
        return "db";
    case Types::UnitBpm:
        return "bpm";
    case Types::UnitKiloByte:
        return "kB";
    case Types::UnitMegaByte:
        return "MB";
    case Types::UnitGigaByte:
        return "GB";
    case Types::UnitTeraByte:
        return "TB";
    case Types::UnitMilliWatt:
        return "mW";
    case Types::UnitWatt:
        return "W";
    case Types::UnitKiloWatt:
        return "kW";
    case Types::UnitKiloWattHour:
        return "kWh";
    case Types::UnitEuroPerMegaWattHour:
        return "€/MWh";
    case Types::UnitEuroCentPerKiloWattHour:
        return "ct/kWh";
    case Types::UnitPercentage:
        return "%";
    case Types::UnitPartsPerMillion:
        return "ppm";
    case Types::UnitEuro:
        return "€";
    case Types::UnitDollar:
        return "$";
    case Types::UnitHertz:
        return "Hz";
    case Types::UnitAmpere:
        return "A";
    case Types::UnitMilliAmpere:
        return "mA";
    case Types::UnitVolt:
        return "V";
    case Types::UnitMilliVolt:
        return "mV";
    case Types::UnitVoltAmpere:
        return "VA";
    case Types::UnitVoltAmpereReactive:
        return "VAR";
    case Types::UnitAmpereHour:
        return "Ah";
    case Types::UnitMicroSiemensPerCentimeter:
        return "µS/cm";
    case Types::UnitDuration:
        return "s";

    // Units not in nymea:core
    case Types::UnitDegreeFahrenheit:
        return "°F";
    case Types::UnitOunce:
        return "oz";
    case Types::UnitPound:
        return "lb";
    case Types::UnitInch:
        return "in";
    case Types::UnitFoot:
        return "ft";
    case Types::UnitMile:
        return "mi";
    case Types::UnitFootPerSecond:
        return "fps";
    case Types::UnitMilePerHour:
        return "mph";
    case Types::UnitPoundsPerSquareInch:
        return "psi";
    case Types::UnitNewton:
        return "N";
    case Types::UnitNewtonMeter:
        return "Nm";
    case Types::UnitRpm:
        return "rpm";
    case Types::UnitMilligramPerLiter:
        return "mg/l";
    case Types::UnitLiter:
        return "l";
    }

    return "";
}

QVariant Types::toUiValue(const QVariant &value, Types::Unit unit) const
{
    if (m_unitSystem == UnitSystemImperial) {
        switch (unit) {
        case Types::UnitDegreeCelsius: // To Fahrenheit
            return (value.toDouble() * 9/5) + 32;
        case Types::UnitGram: // To Ounce
            return value.toDouble() / 28.35;
        case Types::UnitKiloGram: // To Pound
            return value.toDouble() * 2.205;
        case Types::UnitMilliMeter: // To Inch
            return value.toDouble() / 25.4;
        case Types::UnitCentiMeter: // To Inch
            return value.toDouble() / 2.54;
        case Types::UnitMeter: // To Feet
            return value.toDouble() * 3.281;
        case Types::UnitKiloMeter: // To Mile
            return value.toDouble() / 1.609;
        case Types::UnitMeterPerSecond: // To foot per second
            return value.toDouble() * 3.281;
        case Types::UnitKiloMeterPerHour: // To miles per hour
            return value.toDouble() / 1.609;
        case Types::UnitMilliBar: // To pounds per square inch (psi)
            return value.toDouble() * 0.01450377;
        case Types::UnitBar: // To pounds per square inch (psi)
            return value.toDouble() * 14.50377;
        case Types::UnitLiter: // To fl. oz
            return value.toDouble() * 33.814;
        default:
            return value;
        }
    }
    return value;
}
