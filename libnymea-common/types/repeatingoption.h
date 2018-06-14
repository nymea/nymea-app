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
