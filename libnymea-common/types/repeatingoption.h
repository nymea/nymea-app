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

#ifndef REPEATINGOPTION_H
#define REPEATINGOPTION_H

#include <QObject>
#include <QVariantList>

class RepeatingOption: public QObject
{
    Q_OBJECT
    Q_PROPERTY(RepeatingMode repeatingMode READ repeatingMode WRITE setRepeatingMode NOTIFY repeatingModeChanged)
    Q_PROPERTY(QVariantList weekDays READ weekDays WRITE setWeekDays NOTIFY weekDaysChanged)
    Q_PROPERTY(QVariantList monthDays READ monthDays WRITE setMonthDays NOTIFY monthDaysChanged)

public:
    enum RepeatingMode {
        RepeatingModeNone,
        RepeatingModeHourly,
        RepeatingModeDaily,
        RepeatingModeWeekly,
        RepeatingModeMonthly,
        RepeatingModeYearly
    };
    Q_ENUM(RepeatingMode)

    explicit RepeatingOption(QObject *parent = nullptr);

    RepeatingMode repeatingMode() const;
    void setRepeatingMode(RepeatingMode repeatingMode);

    QVariantList weekDays() const;
    void setWeekDays(const QVariantList &weekDays);

    QVariantList monthDays() const;
    void setMonthDays(const QVariantList &monthDays);

signals:
    void repeatingModeChanged();
    void weekDaysChanged();
    void monthDaysChanged();

private:
    RepeatingMode m_repeatingMode = RepeatingModeDaily;
    QVariantList m_weekDays;
    QVariantList m_monthDays;
};


#endif // REPEATINGOPTION_H
