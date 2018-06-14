#include "repeatingoption.h"

RepeatingOption::RepeatingOption(QObject *parent) : QObject(parent)
{

}

RepeatingOption::RepeatingMode RepeatingOption::repeatingMode() const
{
    return m_repeatingMode;
}

void RepeatingOption::setRepeatingMode(RepeatingOption::RepeatingMode repeatingMode)
{
    if (m_repeatingMode != repeatingMode) {
        m_repeatingMode = repeatingMode;
        emit repeatingModeChanged();
    }
}

QVariantList RepeatingOption::weekDays() const
{
    return m_weekDays;
}

void RepeatingOption::setWeekDays(const QVariantList &weekDays)
{
    if (m_weekDays != weekDays) {
        m_weekDays = weekDays;
        emit weekDaysChanged();
    }
}

QVariantList RepeatingOption::monthDays() const
{
    return m_monthDays;
}

void RepeatingOption::setMonthDays(const QVariantList &monthDays)
{
    if (m_monthDays != monthDays) {
        m_monthDays = monthDays;
        emit monthDaysChanged();
    }
}
