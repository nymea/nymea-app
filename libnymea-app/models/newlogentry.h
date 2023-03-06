#ifndef NEWLOGENTRY_H
#define NEWLOGENTRY_H

#include <QObject>
#include <QDateTime>
#include <QVariant>

class NewLogEntry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source CONSTANT)
    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(QVariantMap values READ values CONSTANT)

public:
    explicit NewLogEntry(const QString &source, const QDateTime &timestamp, const QVariantMap &values, QObject *parent = nullptr);

    QString source() const;
    QDateTime timestamp() const;
    QVariantMap values() const;

private:
    QString m_source;
    QDateTime m_timestamp;
    QVariantMap m_values;
};

#endif // NEWLOGENTRY_H
